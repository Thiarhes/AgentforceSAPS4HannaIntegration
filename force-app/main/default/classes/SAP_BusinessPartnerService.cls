public with sharing class SAP_BusinessPartnerService {
    
    // Abstração 1: Objeto de Saída "Achatado" (DTO - Data Transfer Object)
    // Criamos uma classe simples para que o Salesforce não precise lidar com o "Feed/Entry/Content"
    public class BusinessPartnerDTO {
        @AuraEnabled public String sapId;
        @AuraEnabled public String fullName;
        @AuraEnabled public String bpGroup;
        @AuraEnabled public String createdBy;
    }

    /**
     * @description Busca um parceiro de negócio e retorna o dado já "achatado"
     */
    public static BusinessPartnerDTO getBusinessPartner(String partnerId) {
        // Abstração 2: Encapsulamento da Requisição
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Usamos a Named Credential para segurança e o filtro OData para performance
        String encodedId = EncodingUtil.urlEncode(partnerId, 'UTF-8');
        String endpoint = 'callout:SAPS4HANASandbox/A_BusinessPartner(\'' + encodedId + '\')';
        
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');

        try {
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                // Abstração 3: Data Transformation (O "Flatten")
                return flattenResponse(response.getBody());
            } else {
                throw new CalloutException('Erro no SAP: Status ' + response.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Erro de Integração: ' + e.getMessage());
            // Aqui futuramente dispararemos um Platform Event para Observabilidade
            return null;
        }
    }

    /**
     * @description O "Achatador": Converte o Wrapper complexo no nosso DTO simples
     */
    private static BusinessPartnerDTO flattenResponse(String jsonBody) {
        // 1. Usa o Wrapper para parsear o JSON gigante
        SAP_BusinessPartnerWrapper wrapper = SAP_BusinessPartnerWrapper.parse(jsonBody);
        
        // 2. Extrai os dados lá do fundo da estrutura
        SAP_BusinessPartnerWrapper.Properties props = wrapper.feed.entry.content.properties;
        
        // 3. Mapeia para o nosso objeto "limpo" (DTO)
        BusinessPartnerDTO dto = new BusinessPartnerDTO();
        dto.sapId = props.BusinessPartner;
        dto.fullName = props.BusinessPartnerFullName;
        dto.bpGroup = props.BusinessPartnerGrouping;
        dto.createdBy = props.CreatedByUser;
        
        return dto;
    }
}
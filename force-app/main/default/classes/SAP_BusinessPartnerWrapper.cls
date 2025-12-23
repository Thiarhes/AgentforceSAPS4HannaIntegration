public with sharing class SAP_BusinessPartnerWrapper {
    
    // Classes que refletem a estrutura do JSON da SAP
    public Feed feed;

    public class Feed {
        public Entry entry;
    }

    public class Entry {
        public Content content;
    }

    public class Content {
        public Properties properties;
    }

    // Aqui estão os campos que realmente nos interessam
    public class Properties {
        public String BusinessPartner; // ID no SAP
        public String BusinessPartnerFullName;
        public String BusinessPartnerGrouping;
        public String OrganizationBPName1;
        public String CreatedByUser;
    }

    /**
     * @description Transforma o JSON bruto em um objeto Apex
     */
    public static SAP_BusinessPartnerWrapper parse(String json) {
        return (SAP_BusinessPartnerWrapper) System.JSON.deserialize(json, SAP_BusinessPartnerWrapper.class);
    }
}
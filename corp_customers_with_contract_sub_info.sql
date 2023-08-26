SELECT
        a.id AS SF_ACCOUNT_ID
        ,a.NAME as sf_account_name
        ,a.SALES_REGION
        ,a.BILLINGCOUNTRY
        ,coalesce(c.mspbillingtype,a.MSPBILLINGTYPE) as MSPBILLINGTYPE
        ,a.type
        ,a.partner_type
        ,a.test_account
        ,a.sales_team
        --,cc.NAME AS contact_name
        --,cc.primary_contact
        ,nullif(a.TWOTIER_CURRENTMASTERMSP,'') AS master_msp_account_id
        ,ma.NAME AS master_msp_account_name
        ,coalesce(a.MASTER_MSP,false) AS parent_msp_is_master_msp
        ,IFF((u2.TITLE LIKE '%MSP Channel Account Manager%' OR u2."NAME" = 'Alejandro Hage'), u2."NAME", '') AS CAM
        ,IFNULL(u3.NAME, '') AS PSM
         ,nullif(u4.name,'') as am
        --,c.id AS contract_id
        --,c.NAME AS contract_name
        --,c.status AS contract_status
        --,c.startdate AS contract_start_date
        --,c.enddate AS contract_end_date
        --,s.id AS subscription_id
        --,s.NAME AS subscription_name
        --,s.sku AS subscription_sku
        ,sum(s.SBQQ__QUANTITY) AS seats_purchased
        FROM dm_sales.SF_SUBSCRIPTION_CDS s
      INNER JOIN dm_sales.SF_CONTRACT_CDS c ON s.SBQQONTRACT =c.id
      INNER JOIN dm_sales.SF_ACCOUNT_CDS a ON c.ACCOUNTID =a.id --AND a.TEST_ACCOUNT =false
      --LEFT JOIN dm_sales.SF_CONTACT_CDS cc ON cc.ACCOUNTID =a.id
      LEFT JOIN dm_sales.SF_ACCOUNT_CDS ma ON ma.id=nullif(a.TWOTIER_CURRENTMASTERMSP,'')
      LEFT JOIN DM_SALES.SF_USER_CDS u2 ON u2.id = a.OWNERID
      LEFT JOIN DM_SALES.SF_USER_CDS u3 ON u3.id = a.PARTNER_CONSULTANT
      left join DM_SALES.SF_USER_CDS u4 ON u4.id = a.OWNERID
      left join (SELECT DISTINCT sf_sku ,category,is_site_license_sku,Is_crowdstrike_sku  FROM cds.UD_NEBULIFT_MAPPING_CDS) n on s.sku = n.sf_sku
      where
      {% condition contract_status %} c.status {% endcondition %}
      and {% condition sku %} s.sku {% endcondition %}
      and {% condition sku_category %} n.category {% endcondition %}
      and {% condition is_site_license_sku %} n.is_site_license_sku {% endcondition %}
      and {% condition Is_crowdstrike_sku %} n.Is_crowdstrike_sku {% endcondition %}
      group by
        a.id
        ,a.NAME
        ,a.SALES_REGION
        ,a.BILLINGCOUNTRY
        ,coalesce(c.mspbillingtype,a.MSPBILLINGTYPE)
        ,a.type
        ,a.partner_type
        ,a.test_account
        ,a.sales_team
        ,nullif(a.TWOTIER_CURRENTMASTERMSP,'')
        ,ma.NAME
        ,coalesce(a.MASTER_MSP,false)
        ,IFF((u2.TITLE LIKE '%MSP Channel Account Manager%' OR u2."NAME" = 'Alejandro Hage'), u2."NAME", '')
        ,IFNULL(u3.NAME, '')
        ,nullif(u4.name,'')
;

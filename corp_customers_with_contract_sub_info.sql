SELECT
        s.cds_history_insert_ts::date as snapshot_date
        ,a.id AS SF_ACCOUNT_ID
        ,a.NAME as sf_account_name
        ,a.SALES_REGION
        ,a.BILLINGCOUNTRY
        ,a.MSPBILLINGTYPE
        ,a.type
        ,a.partner_type
        ,a.test_account
        ,a.sales_team
        --,cc.NAME AS contact_name
        --,cc.primary_contact
        ,nullif(a.TWOTIER_CURRENTMASTERMSP,'') AS master_msp_account_id
        ,ma.NAME AS master_msp_account_name
        ,coalesce(a.MASTER_MSP,false) AS parent_msp_is_master_msp
        --,IFF((u2.TITLE LIKE '%MSP Channel Account Manager%' OR u2."NAME" = 'Alejandro Hage'), u2."NAME", '') AS CAM
        --,IFNULL(u3.NAME, '') AS PSM
        --,c.id AS contract_id
        --,c.NAME AS contract_name
        --,c.status AS contract_status
        --,c.startdate AS contract_start_date
        --,c.enddate AS contract_end_date
        --,s.id AS subscription_id
        --,s.NAME AS subscription_name
        --,s.sku AS subscription_sku
        ,sum(s.quantity) AS seats_purchased
        FROM CDS.MWB_SF_SUBSCRIPTIONS_PLUS_CDS_HISTORY s
      INNER JOIN dm_sales.SF_CONTRACT_CDS_history c ON s.contract_id =c.id and s.cds_history_insert_ts::date=c.cds_history_insert_ts::date
      INNER JOIN dm_sales.SF_ACCOUNT_CDS_history a ON c.ACCOUNTID =a.id AND a.TEST_ACCOUNT =FALSE and a.cds_history_insert_ts::date=c.cds_history_insert_ts::date
      --LEFT JOIN dm_sales.SF_CONTACT_CDS cc ON cc.ACCOUNTID =a.id
      LEFT JOIN dm_sales.SF_ACCOUNT_CDS_history ma ON ma.id=nullif(a.TWOTIER_CURRENTMASTERMSP,'') and ma.cds_history_insert_ts::date=c.cds_history_insert_ts::date
      --LEFT JOIN DM_SALES.SF_USER_CDS_history u2 ON u2.id = a.OWNERID and s.cds_history_insert_ts::date=u2.cds_history_insert_ts::date
      --LEFT JOIN DM_SALES.SF_USER_CDS_history u3 ON u3.id = a.PARTNER_CONSULTANT and s.cds_history_insert_ts::date=u3.cds_history_insert_ts::date
      where
      {% condition contract_status %} c.status {% endcondition %}
      and {% condition sku %} s.sku {% endcondition %}
      and {% condition snapshot_timeframe %} s.cds_history_insert_ts::date {% endcondition %}
      AND {% condition msp_billing_type_hybrid %} coalesce(NULLIF(c.mspbillingtype,''),a.mspbillingtype) {% endcondition %} --add logic to deal with Upfront Hybrid contracts
      group by
        s.cds_history_insert_ts::date
        ,a.id
        ,a.NAME
        ,a.SALES_REGION
        ,a.BILLINGCOUNTRY
        ,a.MSPBILLINGTYPE
        ,a.type
        ,a.partner_type
        ,a.test_account
        ,a.sales_team
        ,nullif(a.TWOTIER_CURRENTMASTERMSP,'')
        ,ma.NAME
        ,coalesce(a.MASTER_MSP,false)
        --,IFF((u2.TITLE LIKE '%MSP Channel Account Manager%' OR u2."NAME" = 'Alejandro Hage'), u2."NAME", '')
        --,IFNULL(u3.NAME, '')
;

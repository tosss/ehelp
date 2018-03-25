<xml>
	<validLogoutRequest>
		<![CDATA[
			<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' >
			  <soapenv:Header >
				<bm:userInfo xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >
				  <bm:sessionId >0x0234112</bm:sessionId>
				</bm:userInfo>
				<bm:category xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >Security</bm:category>
				<bm:xsdInfo xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >
				  <bm:schemaLocation >https://abc.bigmachines.com/bmfsweb/abc/schema/v1_0/security/Security.xsd</bm:schemaLocation>
				</bm:xsdInfo>
			  </soapenv:Header>
			  <soapenv:Body >
				<bm:logout xmlns:bm='urn:soap.bigmachines.com'  />
			  </soapenv:Body>
			</soapenv:Envelope>
		]]>
	</validLogoutRequest>
	<validLoginRequest>
	   <![CDATA[
	       <soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' >
             <soapenv:Header >
               <bm:category xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >Security</bm:category>
               <bm:xsdInfo xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >
                 <bm:schemaLocation >https://abc.bigmachines.com/bmfsweb/abc/schema/v1_0/security/Security.xsd</bm:schemaLocation>
               </bm:xsdInfo>
             </soapenv:Header>
             <soapenv:Body >
               <bm:login xmlns:bm='urn:soap.bigmachines.com' >
                 <bm:userInfo >
                   <bm:username >abc</bm:username>
                   <bm:password >abc</bm:password>
                 </bm:userInfo>
               </bm:login>
             </soapenv:Body>
           </soapenv:Envelope>
	   ]]>
	</validLoginRequest>
	<validLoginResponse>
	   <![CDATA[
	       <?xml version="1.0" encoding="UTF-8"?>
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
                <soapenv:Body>
                    <bm:loginResponse xmlns:bm="urn:soap.bigmachines.com">
                        <bm:status>
                            <bm:success>true</bm:success>
                            <bm:message>Thu Sep 17 09:09:47 CDT 2015 - Successfully processed API for norion</bm:message>
                        </bm:status>
                        <bm:userInfo>
                            <bm:sessionId>0x0234112</bm:sessionId>
                        </bm:userInfo>
                    </bm:loginResponse>
                </soapenv:Body>
            </soapenv:Envelope>
	   ]]>
	</validLoginResponse>
	<oracleUserSyncRequest1>
	   <![CDATA[
	       <soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' >
              <soapenv:Header >
                <bm:userInfo xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >
                  <bm:sessionId >0x0234112</bm:sessionId>
                </bm:userInfo>
                <bm:category xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >Users</bm:category>
                <bm:xsdInfo xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >
                  <bm:schemaLocation >https://abc.bigmachines.com/bmfsweb/abc/schema/v1_0/users/Users.xsd</bm:schemaLocation>
                </bm:xsdInfo>
              </soapenv:Header>
              <soapenv:Body >
                <bm:updateUsers xmlns:bm='urn:soap.bigmachines.com' >
                  <bm:User >
                    <bm:each_record >
                      <bm:company_name  />
                      <bm:login >testbigmachinessyncuser0</bm:login>
                      <bm:type >blah0</bm:type>
                      <bm:first_name >FirstName0</bm:first_name>
                      <bm:last_name >LastName0</bm:last_name>
                      <bm:job_title >Title</bm:job_title>
                      <bm:email >testuser0@test.com</bm:email>
                      <bm:phone >1234567890</bm:phone>
                      <bm:fax >9999999999</bm:fax>
                      <bm:bm_language >blah0</bm:bm_language>
                      <bm:currency_preference >blah0</bm:currency_preference>
                      <bm:bm_units >blah0</bm:bm_units>
                      <bm:date_format >blah0</bm:date_format>
                      <bm:time_zone >blah0</bm:time_zone>
                      <bm:number_format >blah0</bm:number_format>
                      <bm:send_password_email >false</bm:send_password_email>
                      <bm:approval_delegate  />
                      <bm:partner_login >testbigmachinessyncuser0@test.com</bm:partner_login>
                      <bm:status >Active</bm:status>
                    </bm:each_record>
                  </bm:User>
                  <bm:User >
                    <bm:each_record >
                      <bm:company_name  />
                      <bm:login >testbigmachinessyncuser0</bm:login>
                      <bm:type >blah1</bm:type>
                      <bm:first_name >FirstName0</bm:first_name>
                      <bm:last_name >LastName0</bm:last_name>
                      <bm:job_title >Title</bm:job_title>
                      <bm:email >testuser0@test.com</bm:email>
                      <bm:phone >1234567890</bm:phone>
                      <bm:fax >9999999999</bm:fax>
                      <bm:bm_language >blah1</bm:bm_language>
                      <bm:currency_preference >blah1</bm:currency_preference>
                      <bm:bm_units >blah1</bm:bm_units>
                      <bm:date_format >blah1</bm:date_format>
                      <bm:time_zone >blah1</bm:time_zone>
                      <bm:number_format >blah1</bm:number_format>
                      <bm:send_password_email >false</bm:send_password_email>
                      <bm:approval_delegate  />
                      <bm:partner_login >testbigmachinessyncuser0@test.com</bm:partner_login>
                      <bm:status >Active</bm:status>
                    </bm:each_record>
                  </bm:User>
                  <bm:User >
                    <bm:each_record >
                      <bm:company_name  />
                      <bm:login >testbigmachinessyncuser1</bm:login>
                      <bm:type >blah2</bm:type>
                      <bm:first_name >FirstName1</bm:first_name>
                      <bm:last_name >LastName1</bm:last_name>
                      <bm:job_title >Title</bm:job_title>
                      <bm:email >testuser1@test.com</bm:email>
                      <bm:phone >1234567890</bm:phone>
                      <bm:fax >9999999999</bm:fax>
                      <bm:bm_language >blah2</bm:bm_language>
                      <bm:currency_preference >blah2</bm:currency_preference>
                      <bm:bm_units >blah2</bm:bm_units>
                      <bm:date_format >blah2</bm:date_format>
                      <bm:time_zone >blah2</bm:time_zone>
                      <bm:number_format >blah2</bm:number_format>
                      <bm:send_password_email >false</bm:send_password_email>
                      <bm:approval_delegate  />
                      <bm:partner_login >testbigmachinessyncuser1@test.com</bm:partner_login>
                      <bm:status >Active</bm:status>
                    </bm:each_record>
                  </bm:User>
                  <bm:User >
                    <bm:each_record >
                      <bm:company_name  />
                      <bm:login >testbigmachinessyncuser1</bm:login>
                      <bm:type >blah3</bm:type>
                      <bm:first_name >FirstName1</bm:first_name>
                      <bm:last_name >LastName1</bm:last_name>
                      <bm:job_title >Title</bm:job_title>
                      <bm:email >testuser1@test.com</bm:email>
                      <bm:phone >1234567890</bm:phone>
                      <bm:fax >9999999999</bm:fax>
                      <bm:bm_language >blah3</bm:bm_language>
                      <bm:currency_preference >blah3</bm:currency_preference>
                      <bm:bm_units >blah3</bm:bm_units>
                      <bm:date_format >blah3</bm:date_format>
                      <bm:time_zone >blah3</bm:time_zone>
                      <bm:number_format >blah3</bm:number_format>
                      <bm:send_password_email >false</bm:send_password_email>
                      <bm:approval_delegate  />
                      <bm:partner_login >testbigmachinessyncuser1@test.com</bm:partner_login>
                      <bm:status >Active</bm:status>
                    </bm:each_record>
                  </bm:User>
                </bm:updateUsers>
              </soapenv:Body>
            </soapenv:Envelope>
	   ]]>
	</oracleUserSyncRequest1>
	<oracleUserSyncRequest2>
       <![CDATA[
           <soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' >
              <soapenv:Header >
                <bm:userInfo xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >
                  <bm:sessionId >0x0234112</bm:sessionId>
                </bm:userInfo>
                <bm:category xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >Users</bm:category>
                <bm:xsdInfo xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >
                  <bm:schemaLocation >https://abc.bigmachines.com/bmfsweb/abc/schema/v1_0/users/Users.xsd</bm:schemaLocation>
                </bm:xsdInfo>
              </soapenv:Header>
              <soapenv:Body >
                <bm:updateUsers xmlns:bm='urn:soap.bigmachines.com' >
                  <bm:User >
                    <bm:each_record >
                      <bm:company_name  />
                      <bm:login >testbigmachinessyncuser0</bm:login>
                      <bm:type >blah4</bm:type>
                      <bm:first_name >FirstName0</bm:first_name>
                      <bm:last_name >LastName0</bm:last_name>
                      <bm:job_title >Title</bm:job_title>
                      <bm:email >testuser0@test.com</bm:email>
                      <bm:phone >1234567890</bm:phone>
                      <bm:fax >9999999999</bm:fax>
                      <bm:bm_language >blah4</bm:bm_language>
                      <bm:currency_preference >blah4</bm:currency_preference>
                      <bm:bm_units >blah4</bm:bm_units>
                      <bm:date_format >blah4</bm:date_format>
                      <bm:time_zone >blah4</bm:time_zone>
                      <bm:number_format >blah4</bm:number_format>
                      <bm:send_password_email >false</bm:send_password_email>
                      <bm:approval_delegate  />
                      <bm:partner_login >testbigmachinessyncuser0@test.com</bm:partner_login>
                      <bm:status >Active</bm:status>
                    </bm:each_record>
                  </bm:User>
                  <bm:User >
                    <bm:each_record >
                      <bm:company_name  />
                      <bm:login >testbigmachinessyncuser0</bm:login>
                      <bm:type >blah5</bm:type>
                      <bm:first_name >FirstName0</bm:first_name>
                      <bm:last_name >LastName0</bm:last_name>
                      <bm:job_title >Title</bm:job_title>
                      <bm:email >testuser0@test.com</bm:email>
                      <bm:phone >1234567890</bm:phone>
                      <bm:fax >9999999999</bm:fax>
                      <bm:bm_language >blah5</bm:bm_language>
                      <bm:currency_preference >blah5</bm:currency_preference>
                      <bm:bm_units >blah5</bm:bm_units>
                      <bm:date_format >blah5</bm:date_format>
                      <bm:time_zone >blah5</bm:time_zone>
                      <bm:number_format >blah5</bm:number_format>
                      <bm:send_password_email >false</bm:send_password_email>
                      <bm:approval_delegate  />
                      <bm:partner_login >testbigmachinessyncuser0@test.com</bm:partner_login>
                      <bm:status >Active</bm:status>
                    </bm:each_record>
                  </bm:User>
                  <bm:User >
                    <bm:each_record >
                      <bm:company_name  />
                      <bm:login >testbigmachinessyncuser1</bm:login>
                      <bm:type >blah6</bm:type>
                      <bm:first_name >FirstName1</bm:first_name>
                      <bm:last_name >LastName1</bm:last_name>
                      <bm:job_title >Title</bm:job_title>
                      <bm:email >testuser1@test.com</bm:email>
                      <bm:phone >1234567890</bm:phone>
                      <bm:fax >9999999999</bm:fax>
                      <bm:bm_language >blah6</bm:bm_language>
                      <bm:currency_preference >blah6</bm:currency_preference>
                      <bm:bm_units >blah6</bm:bm_units>
                      <bm:date_format >blah6</bm:date_format>
                      <bm:time_zone >blah6</bm:time_zone>
                      <bm:number_format >blah6</bm:number_format>
                      <bm:send_password_email >false</bm:send_password_email>
                      <bm:approval_delegate  />
                      <bm:partner_login >testbigmachinessyncuser1@test.com</bm:partner_login>
                      <bm:status >Active</bm:status>
                    </bm:each_record>
                  </bm:User>
                  <bm:User >
                    <bm:each_record >
                      <bm:company_name  />
                      <bm:login >testbigmachinessyncuser1</bm:login>
                      <bm:type >blah7</bm:type>
                      <bm:first_name >FirstName1</bm:first_name>
                      <bm:last_name >LastName1</bm:last_name>
                      <bm:job_title >Title</bm:job_title>
                      <bm:email >testuser1@test.com</bm:email>
                      <bm:phone >1234567890</bm:phone>
                      <bm:fax >9999999999</bm:fax>
                      <bm:bm_language >blah7</bm:bm_language>
                      <bm:currency_preference >blah7</bm:currency_preference>
                      <bm:bm_units >blah7</bm:bm_units>
                      <bm:date_format >blah7</bm:date_format>
                      <bm:time_zone >blah7</bm:time_zone>
                      <bm:number_format >blah7</bm:number_format>
                      <bm:send_password_email >false</bm:send_password_email>
                      <bm:approval_delegate  />
                      <bm:partner_login >testbigmachinessyncuser1@test.com</bm:partner_login>
                      <bm:status >Active</bm:status>
                    </bm:each_record>
                  </bm:User>
                </bm:updateUsers>
              </soapenv:Body>
            </soapenv:Envelope>
       ]]>
    </oracleUserSyncRequest2>
    <oracleUserSyncRequestSingle>
        <![CDATA[
            <soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' >
              <soapenv:Header >
                <bm:userInfo xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >
                  <bm:sessionId >0x0234112</bm:sessionId>
                </bm:userInfo>
                <bm:category xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >Users</bm:category>
                <bm:xsdInfo xmlns:bm='urn:soap.bigmachines.com' soapenv:actor='http://schemas.xmlsoap.org/soap/actor/next' soapenv:mustUnderstand='0' >
                  <bm:schemaLocation >https://abc.bigmachines.com/bmfsweb/abc/schema/v1_0/users/Users.xsd</bm:schemaLocation>
                </bm:xsdInfo>
              </soapenv:Header>
              <soapenv:Body >
                <bm:updateUsers xmlns:bm='urn:soap.bigmachines.com' >
                  <bm:User >
                    <bm:each_record >
                      <bm:company_name  />
                      <bm:login >lasdkjfa</bm:login>
                      <bm:type >blah0</bm:type>
                      <bm:first_name  />
                      <bm:last_name >lsakjfds</bm:last_name>
                      <bm:job_title  />
                      <bm:email >lasdkjfa@alsdkf.com</bm:email>
                      <bm:phone  />
                      <bm:fax >5</bm:fax>
                      <bm:bm_language >blah0</bm:bm_language>
                      <bm:currency_preference >blah0</bm:currency_preference>
                      <bm:bm_units >blah0</bm:bm_units>
                      <bm:date_format >blah0</bm:date_format>
                      <bm:time_zone >blah0</bm:time_zone>
                      <bm:number_format >blah0</bm:number_format>
                      <bm:send_password_email >false</bm:send_password_email>
                      <bm:approval_delegate  />
                      <bm:partner_login >lasdkjfa@alsdkf.com</bm:partner_login>
                      <bm:status >Active</bm:status>
                    </bm:each_record>
                  </bm:User>
                </bm:updateUsers>
              </soapenv:Body>
            </soapenv:Envelope>
        ]]>
    </oracleUserSyncRequestSingle>
	<oracleUserSyncResponse>
	   <![CDATA[
	       <?xml version="1.0" encoding="UTF-8"?>
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
                <soapenv:Body>
                    <bm:updateUsersResponse xmlns:bm="urn:soap.bigmachines.com">
                        <bm:status>
                            <bm:success>true</bm:success>
                            <bm:message>Thu Sep 17 10:11:02 CDT 2015 - Successfully processed API for norion</bm:message>
                            <bm:records_read>4</bm:records_read>
                            <bm:records_failed>0</bm:records_failed>
                        </bm:status>
                        <bm:detailedStatus>
                            <bm:record>
                                <bm:successful>true</bm:successful>
                            </bm:record>
                            <bm:record>
                                <bm:successful>true</bm:successful>
                            </bm:record>
                            <bm:record>
                                <bm:successful>true</bm:successful>
                            </bm:record>
                            <bm:record>
                                <bm:successful>true</bm:successful>
                            </bm:record>
                        </bm:detailedStatus>
                    </bm:updateUsersResponse>
                </soapenv:Body>
            </soapenv:Envelope>
	   ]]>
	</oracleUserSyncResponse>
	<oracleUserSyncResponseSingle>
       <![CDATA[
           <?xml version="1.0" encoding="UTF-8"?>
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
                <soapenv:Body>
                    <bm:updateUsersResponse xmlns:bm="urn:soap.bigmachines.com">
                        <bm:status>
                            <bm:success>true</bm:success>
                            <bm:message>Thu Sep 17 10:11:02 CDT 2015 - Successfully processed API for norion</bm:message>
                            <bm:records_read>1</bm:records_read>
                            <bm:records_failed>0</bm:records_failed>
                        </bm:status>
                        <bm:detailedStatus>
                            <bm:record>
                                <bm:successful>true</bm:successful>
                            </bm:record>
                        </bm:detailedStatus>
                    </bm:updateUsersResponse>
                </soapenv:Body>
            </soapenv:Envelope>
       ]]>
    </oracleUserSyncResponseSingle>
	<invalidOracleUserSyncResponse>
	    <?xml version="1.0" encoding="UTF-8"?>
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
            <soapenv:Body>
                <bm:updateUsersResponse xmlns:bm="urn:soap.bigmachines.com">
                    <bm:status>
                        <bm:success>true</bm:success>
                        <bm:message>Thu Sep 17 11:47:49 CDT 2015 - Successfully processed API for norion</bm:message>
                        <bm:records_read>4</bm:records_read>
                        <bm:records_failed>2</bm:records_failed>
                    </bm:status>
                    <bm:detailedStatus>
                        <bm:record>
                            <bm:successful>false</bm:successful>
                            <bm:message>Email is required.</bm:message>
                        </bm:record>
                        <bm:record>
                            <bm:successful>true</bm:successful>
                        </bm:record>
                        <bm:record>
                            <bm:successful>true</bm:successful>
                        </bm:record>
                        <bm:record>
                            <bm:successful>false</bm:successful>
                            <bm:message>Email is required.</bm:message>
                        </bm:record>
                    </bm:detailedStatus>
                </bm:updateUsersResponse>
            </soapenv:Body>
        </soapenv:Envelope>
	</invalidOracleUserSyncResponse>
</xml>
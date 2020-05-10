IntegrationNode:
  ACENODE1:
    IntegrationServer:
      - EG1
#      - EG2
    SecurityCredentials:
      - MQ_CR1:
        name: mq::QMCLOUD1
        user: eduard
        password: 123SDF
      - QDBC1:
        name: odbc::PRJDB2
        user: project
        password: xxxyyy
      - LDAP1:
        name: ldap::LDAP
        user: uid=moriz,ou=Users,o=5e9383690118300cc6acd03a,dc=jumpcloud,dc=com
        password: Qwertz12345$        
#IntegrationServer:
#  MYSRV1:
#    workdir: /home/wbiadm11/mysrv1
#    vaultkey: 12334asdfg
#    SecurityCredentials:
#      - JDBC1:
#        name: jdbc_demo1
#        type: jdbc
#        user: asbc
#        password: 733hzwz
#      - SMTP1:
#        name: smtp_demo1
#        type: smtp
#        user: file1
#        password: 83838e        

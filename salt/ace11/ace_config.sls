{% set iib_user = 'wbiadm11' %}

# Iterate over the integration nodes in pillars
{% for node_name in salt['pillar.get']('IntegrationNode') %}
NodeCreated{{ node_name }}:
  cmd.run:
    - name: mqsilist {{ node_name }}
    - runas: {{ iib_user }}
    
NodeSetup{{ node_name }}:
  cmd.run:
    - name: mqsicreatebroker {{ node_name }} && mqsistart {{ node_name }}
    - runas: {{ iib_user }}
    - onfail:
      - cmd: NodeCreated{{ node_name }}
# Iterate over the integration servers in pillars      
{% for srv_name in salt['pillar.get']('IntegrationNode:' ~ node_name ~ ':IntegrationServer') %}      
ServerCreated{{ node_name }}{{ srv_name }}:
  cmd.run:
    - name: mqsilist {{ node_name }} -e {{ srv_name }}
    - runas: {{ iib_user }}
    
ServerSetup{{ node_name }}{{ srv_name }}:
  cmd.run:
    - name: mqsicreateexecutiongroup {{ node_name }} -e {{ srv_name }}
    - runas: {{ iib_user }}
    - onfail:
      - cmd: ServerCreated{{ node_name }}{{ srv_name }}
{% endfor %} 

# Iterate over the security credentials in pillars
{% for cred in salt['pillar.get']('IntegrationNode:' ~ node_name ~ ':SecurityCredentials') %}
{% set resource_name = cred['name'] %}
{% set user = cred['user'] %}
{% set password = cred['password'] %}
Credential{{ node_name }}{{ resource_name }}:
  cmd.run:
    - name: mqsisetdbparms {{ node_name }} -n {{ resource_name }} -u {{ user }} -p {{ password }}
    - runas: {{ iib_user }}

{% endfor %} 

NodeRestart{{ node_name }}:
  cmd.run:
    - name: mqsistop {{ node_name }} && mqsistart {{ node_name }}
    - runas: {{ iib_user }}
    - require:
      - cmd: NodeSetup{{ node_name }}

{% endfor %}   

# Iterate over the integration servers in pillars
{% for int_srv in salt['pillar.get']('IntegrationServer') %}
{% set workdir = salt['pillar.get']('IntegrationServer:' ~ int_srv ~ ':workdir') %}
{% set vaultkey = salt['pillar.get']('IntegrationServer:' ~ int_srv ~ ':vaultkey') %}
WorkdirExists{{ int_srv }}:
  file.exists:
    - name: {{ workdir }}
    
WorkdirCreate{{ int_srv }}:
  cmd.run:
    - name: mqsicreateworkdir {{ workdir }}
    - runas: {{ iib_user }}
    - onfail:
      - file: WorkdirExists{{ int_srv }}

{% if vaultkey %}
VaultDestroy{{ vaultkey }}:
  cmd.run:
    - name: mqsivault --work-dir {{ workdir }} --destroy
    - runas: {{ iib_user }}
    - require:
      - cmd: WorkdirCreate{{ int_srv }}

VaultCreate{{ vaultkey }}:
  cmd.run:
    - name: mqsivault --work-dir {{ workdir }} --create --vault-key {{ vaultkey }}
    - runas: {{ iib_user }}
    - require:
      - cmd: WorkdirCreate{{ int_srv }}

# Iterate over the security credentials in pillars
{% for cred in salt['pillar.get']('IntegrationServer:' ~ int_srv ~ ':SecurityCredentials') %}
{% set resource_name = cred['name'] %}
{% set cred_type = cred['type'] %}
{% set user = cred['user'] %}
{% set password = cred['password'] %}
Credential{{ int_srv }}{{ resource_name }}:
  cmd.run:
    - name: mqsicredentials --work-dir {{ workdir }} --create --credential-name {{ resource_name }} --vault-key {{ vaultkey }} --credential-type {{ cred_type }} --username {{ user }} --password {{ password }}
    - runas: {{ iib_user }}
    - require:
      - cmd: VaultCreate{{ vaultkey }}    

{% endfor %}    

ServerStart{{ int_srv }}:
  cmd.run:
    - name: IntegrationServer --name {{ int_srv }} --work-dir {{ workdir }} --vault-key {{ vaultkey }}>{{ workdir }}/{{ int_srv }}.log 2>&1 &
    - runas: {{ iib_user }}
    - bgFalse: True
    - require:
      - cmd: WorkdirCreate{{ int_srv }}
      - cmd: VaultCreate{{ vaultkey }}

{% else %}
ServerStart{{ int_srv }}:
  cmd.run:
    - name: IntegrationServer --name {{ int_srv }} --work-dir {{ workdir }}>{{ workdir }}/{{ int_srv }}.log 2>&1 &
    - runas: {{ iib_user }}
    - bgFalse: True
    - require:
      - cmd: WorkdirCreate{{ int_srv }}

    
{% endif %}

{% endfor %} 

    

# creating ACE OS user and group
wbiadm11:
  user.present:
    - name: wbiadm11
    - fullname: IBM IIB administrator
    - shell: /bin/bash
    - home: /home/wbiadm11
    - uid: 4001
    - gid: users
    - password: oneclick
    - hash_password: True
    - system: True

mqbrkrs:
  group.present:
    - system: True
    - addusers:
      - wbiadm11

require 'spec_helper'
require 'aws/templates/utils'

# rubocop:disable Metrics/BlockLength
describe UserDirectory do
  let(:directory) do
    UserDirectory::Artifacts::Organization.new(name: 'example.com', root: Object.new) do
      artifact(UserDirectory::Artifacts::Unit, name: 'Business') do
        artifact(
          UserDirectory::Artifacts::Team,
          name: 'Sales',
          group_id: 120,
          manager: {
            id: 1000,
            login: 'wcorner',
            given_name: 'Will',
            middle_name: 'John',
            last_name: 'Corner',
            phone: '+13434345656'
          },
          subordinates: [
            {
              id: 1001,
              login: 'ptsmth',
              given_name: 'Peter',
              middle_name: 'Will',
              last_name: 'Smith',
              phone: '+13434343434'
            },
            {
              id: 1002,
              login: 'joshrx',
              given_name: 'Joshua',
              last_name: 'Revoux',
              phone: '+1343930434'
            },
            {
              id: 1003,
              login: 'helbuck',
              given_name: 'Helmut',
              middle_name: 'V',
              last_name: 'Prust',
              phone: '+13434347654'
            }
          ]
        )

        artifact(
          UserDirectory::Artifacts::Team,
          name: 'Finances',
          group_id: 110,
          manager: {
            id: 1010,
            login: 'lcorner',
            given_name: 'Lisa',
            last_name: 'Corner',
            phone: '+13434345656'
          },
          subordinates: [
            {
              id: 1011,
              login: 'rickk',
              given_name: 'Rick',
              last_name: 'Kim',
              phone: '+13434343876'
            },
            {
              id: 1012,
              login: 'jjohn',
              given_name: 'Jay',
              last_name: 'John',
              phone: '+1343937667'
            }
          ]
        )

        artifact UserDirectory::Artifacts::Group,
                 name: 'business',
                 id: 100,
                 members: search(klass: UserDirectory::Artifacts::User, recursive: true)
      end

      artifact(UserDirectory::Artifacts::Unit, name: 'Engineering', shell: { path: '/bin/zsh' }) do
        artifact(
          UserDirectory::Artifacts::Team,
          name: 'Production',
          group_id: 210,
          manager: {
            id: 2000,
            login: 'wiknoz',
            given_name: 'Wik',
            last_name: 'Nozer',
            phone: '+14564345656'
          },
          subordinates: [
            {
              id: 2001,
              login: 'bmillen',
              given_name: 'Robert',
              last_name: 'Millen',
              phone: '+14564343876'
            },
            {
              id: 2002,
              login: 'xxor',
              given_name: 'Xavier',
              last_name: 'Xordoux',
              phone: '+14564343345'
            }
          ]
        )

        artifact(
          UserDirectory::Artifacts::Team,
          name: 'Development',
          group_id: 220,
          manager: {
            id: 2020,
            login: 'reztrant',
            given_name: 'Trant',
            last_name: 'Reezner',
            phone: '+14564809656'
          },
          subordinates: [
            {
              id: 2021,
              login: 'dxrelk',
              given_name: 'Dexter',
              last_name: 'Relk',
              phone: '+14564347646'
            },
            {
              id: 2022,
              login: 'mi5',
              given_name: 'Michael',
              last_name: 'Five',
              phone: '+14564876345'
            },
            {
              id: 2023,
              login: 'uran',
              given_name: 'Ulrich',
              last_name: 'Randel',
              phone: '+10984876345'
            }
          ]
        )

        artifact(
          UserDirectory::Artifacts::Team,
          name: 'QA',
          group_id: 230,
          manager: {
            id: 2030,
            login: 'qwerty',
            given_name: 'Q',
            last_name: 'Werty',
            phone: '+14564809656'
          },
          subordinates: [
            {
              id: 2031,
              login: 'rrich',
              given_name: 'Rick',
              last_name: 'Richards',
              phone: '+14565677646'
            },
            {
              id: 2032,
              login: 'jojo',
              given_name: 'John',
              last_name: 'Joque',
              phone: '+14568476345'
            },
            {
              id: 2033,
              login: 'predate',
              given_name: 'Patrick',
              last_name: 'Redate',
              phone: '+10988476345'
            }
          ]
        )

        artifact UserDirectory::Artifacts::Group,
                 name: 'engineering',
                 id: 200,
                 members: search(klass: UserDirectory::Artifacts::User, recursive: true)
      end

      artifact UserDirectory::Artifacts::Group,
               name: 'managers',
               id: 300,
               members: search(label: 'manager', recursive: true)
    end
  end

  describe 'etc render' do
    let(:rendered) { UserDirectory::Rendering::Etc::Render.process(directory) }

    let(:expected) do
      UserDirectory::Rendering::Etc::Diff.new(
        [
          'wcorner:x:1000:120:Will Corner (wcorner),,+13434345656:/home/wcorner:/bin/sh',
          'ptsmth:x:1001:120:Peter Smith (ptsmth),,+13434343434:/home/ptsmth:/bin/sh',
          'joshrx:x:1002:120:Joshua Revoux (joshrx),,+1343930434:/home/joshrx:/bin/sh',
          'helbuck:x:1003:120:Helmut Prust (helbuck),,+13434347654:/home/helbuck:/bin/sh',
          'lcorner:x:1010:110:Lisa Corner (lcorner),,+13434345656:/home/lcorner:/bin/sh',
          'rickk:x:1011:110:Rick Kim (rickk),,+13434343876:/home/rickk:/bin/sh',
          'jjohn:x:1012:110:Jay John (jjohn),,+1343937667:/home/jjohn:/bin/sh',
          'wiknoz:x:2000:210:Wik Nozer (wiknoz),,+14564345656:/home/wiknoz:/bin/zsh',
          'bmillen:x:2001:210:Robert Millen (bmillen),,+14564343876:/home/bmillen:/bin/zsh',
          'xxor:x:2002:210:Xavier Xordoux (xxor),,+14564343345:/home/xxor:/bin/zsh',
          'reztrant:x:2020:220:Trant Reezner (reztrant),,+14564809656:/home/reztrant:/bin/zsh',
          'dxrelk:x:2021:220:Dexter Relk (dxrelk),,+14564347646:/home/dxrelk:/bin/zsh',
          'mi5:x:2022:220:Michael Five (mi5),,+14564876345:/home/mi5:/bin/zsh',
          'uran:x:2023:220:Ulrich Randel (uran),,+10984876345:/home/uran:/bin/zsh',
          'qwerty:x:2030:230:Q Werty (qwerty),,+14564809656:/home/qwerty:/bin/zsh',
          'rrich:x:2031:230:Rick Richards (rrich),,+14565677646:/home/rrich:/bin/zsh',
          'jojo:x:2032:230:John Joque (jojo),,+14568476345:/home/jojo:/bin/zsh',
          'predate:x:2033:230:Patrick Redate (predate),,+10988476345:/home/predate:/bin/zsh'
        ], [
          'sales:x:120:ptsmth,joshrx,helbuck,wcorner',
          'finances:x:110:rickk,jjohn,lcorner',
          'business:x:100:wcorner,ptsmth,joshrx,helbuck,lcorner,rickk,jjohn',
          'production:x:210:bmillen,xxor,wiknoz',
          'development:x:220:dxrelk,mi5,uran,reztrant',
          'qa:x:230:rrich,jojo,predate,qwerty',
          'engineering:x:200:wiknoz,bmillen,xxor,reztrant,dxrelk,mi5,' \
            'uran,qwerty,rrich,jojo,predate',
          'managers:x:300:wcorner,lcorner,wiknoz,reztrant,qwerty'
        ]
      )
    end

    it 'returns expected etc format with group and passwd section' do
      expect(rendered).to be == expected
    end
  end

  describe 'ldap render' do
    let(:rendered) { UserDirectory::Rendering::Ldap::Render.process(directory) }

    let(:expected) do
      [
        {
          dn: 'o=example.com',
          objectClass: %w[top organization],
          o: 'example.com'
        }, {
          dn: 'ou=Business,o=example.com',
          objectClass: %w[top organizationalUnit],
          ou: 'Business'
        }, {
          dn: 'ou=Sales,ou=Business,o=example.com',
          objectClass: %w[top organizationalUnit],
          ou: 'Sales'
        }, {
          dn: 'cn=sales,ou=System,o=example.com',
          objectClass: %w[top posixGroup],
          cn: 'sales',
          gidNumber: 120,
          memberUid: %w[ptsmth joshrx helbuck wcorner]
        }, {
          dn: 'cn=Will Corner (wcorner),ou=Sales,ou=Business,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Will Corner (wcorner)',
          uid: 'wcorner',
          uidNumber: 1000,
          gidNumber: 120,
          homeDirectory: '/home/wcorner',
          loginShell: '/bin/sh',
          gecos: 'Will Corner (wcorner),,+13434345656',
          givenName: 'Will',
          sn: 'Corner'
        }, {
          dn: 'cn=Peter Smith (ptsmth),ou=Sales,ou=Business,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Peter Smith (ptsmth)',
          uid: 'ptsmth',
          uidNumber: 1001,
          gidNumber: 120,
          homeDirectory: '/home/ptsmth',
          loginShell: '/bin/sh',
          gecos: 'Peter Smith (ptsmth),,+13434343434',
          givenName: 'Peter',
          sn: 'Smith',
          manager: 'cn=Will Corner (wcorner),ou=Sales,ou=Business,o=example.com'
        }, {
          dn: 'cn=Joshua Revoux (joshrx),ou=Sales,ou=Business,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Joshua Revoux (joshrx)',
          uid: 'joshrx',
          uidNumber: 1002,
          gidNumber: 120,
          homeDirectory: '/home/joshrx',
          loginShell: '/bin/sh',
          gecos: 'Joshua Revoux (joshrx),,+1343930434',
          givenName: 'Joshua',
          sn: 'Revoux',
          manager: 'cn=Will Corner (wcorner),ou=Sales,ou=Business,o=example.com'
        }, {
          dn: 'cn=Helmut Prust (helbuck),ou=Sales,ou=Business,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Helmut Prust (helbuck)',
          uid: 'helbuck',
          uidNumber: 1003,
          gidNumber: 120,
          homeDirectory: '/home/helbuck',
          loginShell: '/bin/sh',
          gecos: 'Helmut Prust (helbuck),,+13434347654',
          givenName: 'Helmut',
          sn: 'Prust',
          manager: 'cn=Will Corner (wcorner),ou=Sales,ou=Business,o=example.com'
        }, {
          dn: 'ou=Finances,ou=Business,o=example.com',
          objectClass: %w[top organizationalUnit],
          ou: 'Finances'
        }, {
          dn: 'cn=finances,ou=System,o=example.com',
          objectClass: %w[top posixGroup],
          cn: 'finances',
          gidNumber: 110,
          memberUid: %w[rickk jjohn lcorner]
        }, {
          dn: 'cn=Lisa Corner (lcorner),ou=Finances,ou=Business,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Lisa Corner (lcorner)',
          uid: 'lcorner',
          uidNumber: 1010,
          gidNumber: 110,
          homeDirectory: '/home/lcorner',
          loginShell: '/bin/sh',
          gecos: 'Lisa Corner (lcorner),,+13434345656',
          givenName: 'Lisa',
          sn: 'Corner'
        }, {
          dn: 'cn=Rick Kim (rickk),ou=Finances,ou=Business,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Rick Kim (rickk)',
          uid: 'rickk',
          uidNumber: 1011,
          gidNumber: 110,
          homeDirectory: '/home/rickk',
          loginShell: '/bin/sh',
          gecos: 'Rick Kim (rickk),,+13434343876',
          givenName: 'Rick',
          sn: 'Kim',
          manager: 'cn=Lisa Corner (lcorner),ou=Finances,ou=Business,o=example.com'
        }, {
          dn: 'cn=Jay John (jjohn),ou=Finances,ou=Business,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Jay John (jjohn)',
          uid: 'jjohn',
          uidNumber: 1012,
          gidNumber: 110,
          homeDirectory: '/home/jjohn',
          loginShell: '/bin/sh',
          gecos: 'Jay John (jjohn),,+1343937667',
          givenName: 'Jay',
          sn: 'John',
          manager: 'cn=Lisa Corner (lcorner),ou=Finances,ou=Business,o=example.com'
        }, {
          dn: 'cn=business,ou=System,o=example.com',
          objectClass: %w[top posixGroup],
          cn: 'business',
          gidNumber: 100,
          memberUid: %w[wcorner ptsmth joshrx helbuck lcorner rickk jjohn]
        }, {
          dn: 'ou=Engineering,o=example.com',
          objectClass: %w[top organizationalUnit],
          ou: 'Engineering'
        }, {
          dn: 'ou=Production,ou=Engineering,o=example.com',
          objectClass: %w[top organizationalUnit],
          ou: 'Production'
        }, {
          dn: 'cn=production,ou=System,o=example.com',
          objectClass: %w[top posixGroup],
          cn: 'production',
          gidNumber: 210,
          memberUid: %w[bmillen xxor wiknoz]
        }, {
          dn: 'cn=Wik Nozer (wiknoz),ou=Production,ou=Engineering,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Wik Nozer (wiknoz)',
          uid: 'wiknoz',
          uidNumber: 2000,
          gidNumber: 210,
          homeDirectory: '/home/wiknoz',
          loginShell: '/bin/zsh',
          gecos: 'Wik Nozer (wiknoz),,+14564345656',
          givenName: 'Wik',
          sn: 'Nozer'
        }, {
          dn: 'cn=Robert Millen (bmillen),ou=Production,ou=Engineering,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Robert Millen (bmillen)',
          uid: 'bmillen',
          uidNumber: 2001,
          gidNumber: 210,
          homeDirectory: '/home/bmillen',
          loginShell: '/bin/zsh',
          gecos: 'Robert Millen (bmillen),,+14564343876',
          givenName: 'Robert',
          sn: 'Millen',
          manager: 'cn=Wik Nozer (wiknoz),ou=Production,ou=Engineering,o=example.com'
        }, {
          dn: 'cn=Xavier Xordoux (xxor),ou=Production,ou=Engineering,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Xavier Xordoux (xxor)',
          uid: 'xxor',
          uidNumber: 2002,
          gidNumber: 210,
          homeDirectory: '/home/xxor',
          loginShell: '/bin/zsh',
          gecos: 'Xavier Xordoux (xxor),,+14564343345',
          givenName: 'Xavier',
          sn: 'Xordoux',
          manager: 'cn=Wik Nozer (wiknoz),ou=Production,ou=Engineering,o=example.com'
        }, {
          dn: 'ou=Development,ou=Engineering,o=example.com',
          objectClass: %w[top organizationalUnit],
          ou: 'Development'
        }, {
          dn: 'cn=development,ou=System,o=example.com',
          objectClass: %w[top posixGroup],
          cn: 'development',
          gidNumber: 220,
          memberUid: %w[dxrelk mi5 uran reztrant]
        }, {
          dn: 'cn=Trant Reezner (reztrant),ou=Development,ou=Engineering,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Trant Reezner (reztrant)',
          uid: 'reztrant',
          uidNumber: 2020,
          gidNumber: 220,
          homeDirectory: '/home/reztrant',
          loginShell: '/bin/zsh',
          gecos: 'Trant Reezner (reztrant),,+14564809656',
          givenName: 'Trant',
          sn: 'Reezner'
        }, {
          dn: 'cn=Dexter Relk (dxrelk),ou=Development,ou=Engineering,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Dexter Relk (dxrelk)',
          uid: 'dxrelk',
          uidNumber: 2021,
          gidNumber: 220,
          homeDirectory: '/home/dxrelk',
          loginShell: '/bin/zsh',
          gecos: 'Dexter Relk (dxrelk),,+14564347646',
          givenName: 'Dexter',
          sn: 'Relk',
          manager: 'cn=Trant Reezner (reztrant),ou=Development,ou=Engineering,o=example.com'
        }, {
          dn: 'cn=Michael Five (mi5),ou=Development,ou=Engineering,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Michael Five (mi5)',
          uid: 'mi5',
          uidNumber: 2022,
          gidNumber: 220,
          homeDirectory: '/home/mi5',
          loginShell: '/bin/zsh',
          gecos: 'Michael Five (mi5),,+14564876345',
          givenName: 'Michael',
          sn: 'Five',
          manager: 'cn=Trant Reezner (reztrant),ou=Development,ou=Engineering,o=example.com'
        }, {
          dn: 'cn=Ulrich Randel (uran),ou=Development,ou=Engineering,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Ulrich Randel (uran)',
          uid: 'uran',
          uidNumber: 2023,
          gidNumber: 220,
          homeDirectory: '/home/uran',
          loginShell: '/bin/zsh',
          gecos: 'Ulrich Randel (uran),,+10984876345',
          givenName: 'Ulrich',
          sn: 'Randel',
          manager: 'cn=Trant Reezner (reztrant),ou=Development,ou=Engineering,o=example.com'
        }, {
          dn: 'ou=QA,ou=Engineering,o=example.com',
          objectClass: %w[top organizationalUnit],
          ou: 'QA'
        }, {
          dn: 'cn=qa,ou=System,o=example.com',
          objectClass: %w[top posixGroup],
          cn: 'qa',
          gidNumber: 230,
          memberUid: %w[rrich jojo predate qwerty]
        }, {
          dn: 'cn=Q Werty (qwerty),ou=QA,ou=Engineering,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Q Werty (qwerty)',
          uid: 'qwerty',
          uidNumber: 2030,
          gidNumber: 230,
          homeDirectory: '/home/qwerty',
          loginShell: '/bin/zsh',
          gecos: 'Q Werty (qwerty),,+14564809656',
          givenName: 'Q',
          sn: 'Werty'
        }, {
          dn: 'cn=Rick Richards (rrich),ou=QA,ou=Engineering,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Rick Richards (rrich)',
          uid: 'rrich',
          uidNumber: 2031,
          gidNumber: 230,
          homeDirectory: '/home/rrich',
          loginShell: '/bin/zsh',
          gecos: 'Rick Richards (rrich),,+14565677646',
          givenName: 'Rick',
          sn: 'Richards',
          manager: 'cn=Q Werty (qwerty),ou=QA,ou=Engineering,o=example.com'
        }, {
          dn: 'cn=John Joque (jojo),ou=QA,ou=Engineering,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'John Joque (jojo)',
          uid: 'jojo',
          uidNumber: 2032,
          gidNumber: 230,
          homeDirectory: '/home/jojo',
          loginShell: '/bin/zsh',
          gecos: 'John Joque (jojo),,+14568476345',
          givenName: 'John',
          sn: 'Joque',
          manager: 'cn=Q Werty (qwerty),ou=QA,ou=Engineering,o=example.com'
        }, {
          dn: 'cn=Patrick Redate (predate),ou=QA,ou=Engineering,o=example.com',
          objectClass: %w[top posixAccount inetOrgPerson person],
          cn: 'Patrick Redate (predate)',
          uid: 'predate',
          uidNumber: 2033,
          gidNumber: 230,
          homeDirectory: '/home/predate',
          loginShell: '/bin/zsh',
          gecos: 'Patrick Redate (predate),,+10988476345',
          givenName: 'Patrick',
          sn: 'Redate',
          manager: 'cn=Q Werty (qwerty),ou=QA,ou=Engineering,o=example.com'
        }, {
          dn: 'cn=engineering,ou=System,o=example.com',
          objectClass: %w[top posixGroup],
          cn: 'engineering',
          gidNumber: 200,
          memberUid: %w[
            wiknoz bmillen xxor reztrant dxrelk mi5 uran qwerty rrich
            jojo predate
          ]
        }, {
          dn: 'cn=managers,ou=System,o=example.com',
          objectClass: %w[top posixGroup],
          cn: 'managers',
          gidNumber: 300,
          memberUid: %w[wcorner lcorner wiknoz reztrant qwerty]
        }
      ]
    end

    it 'returns expected LDIF definition' do
      expect(rendered).to be == expected
    end
  end
end
# rubocop:enable Metrics/BlockLength

### Admins
{{ range .Values.opers.admins }}
  oper {{ .username }} {
    mask *;
    password {{ .password | quote }} { {{ .type }}; };
    class clients;
    operclass netadmin-with-override;
    modes "+q";
    swhois "is a Network Administrator";
  };
{{ end }}

### IRCops
{{ range .Values.opers.ops }}
  oper {{ .username }} {
    mask *;
    password {{ .password | quote }} { {{ .type }}; };
    class clients;
    operclass admin-with-override;
    modes "+q";
    swhois "is a Co Administrator";
  };
{{ end }}

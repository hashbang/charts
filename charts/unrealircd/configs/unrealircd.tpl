{{ if .Values.unrealircd.includes }}
{{ range .Values.unrealircd.includes }}
  include {{ . | quote }}
{{ end }}
{{ end }}

{{ if .Values.unrealircd.admin }}
admin {
  {{ with .Values.unrealircd.admin -}}
  {{ .name | quote  }};
  {{ .email | quote }};
  {{- end }}
};
{{ end }}

{{ if .Values.unrealircd.me }}
me {
  {{ with .Values.unrealircd.me -}}
  name {{ .name }};
  info {{ .info | quote }};
  sid {{ .sid }};
  {{- end }}
};
{{ end }}

{{ if .Values.unrealircd.clients }}
class clients {
  {{- range $key, $val := .Values.unrealircd.clients }}
  {{ $key }} {{ $val }};
  {{ end }}
};
{{ end }}

{{ if .Values.unrealircd.servers }}
class servers {
  {{- range $key, $val := .Values.unrealircd.clients }}
  {{ $key }} {{ $val }};
  {{ end }}
};
{{ end }}

{{ with .Values.unrealircd.links -}}
{{ range . -}}
link {{ .hostname }} {
  username {{ .username }};
  hostname {{ .hostname | quote }};
  port {{ .port }};
  password-connect {{ .password | quote }};
  password-receive {{ .password | quote }};
  hub {{ .hub }};
  class {{ .class }};
  options {
    {{- range .options }}
    {{ . }};
    {{- end }}
  };
};
{{- end }}
{{- end }}

{{ with .Values.unrealircd.services -}}
{{ range . -}}
  link {{ .outgoing.hostname }} {
  incoming {
    mask {{ .incoming.mask }};
  };
  outgoing {
    bind-ip {{ .outgoing.bind_ip }};
    hostname {{ .outgoing.hostname }};
    port {{ .outgoing.port }};
    options {
      {{- range .outgoing.options }}
      {{ . }};
      {{- end }}
    };
  };
  class {{ .class }};
  password {{ .password | quote }};
};
{{- end }}
{{- end }}

{{- with .Values.unrealircd.ulines -}}
{{ range . -}}
ulines { {{ . }}; };
{{- end }}
{{- end }}

{{ with .Values.unrealircd.banned_nicks -}}
{{ range . -}}
ban nick {
  mask {{ . | quote }};
  reason "Reserved for services.";
};
{{ end -}}
{{- end }}

{{ with .Values.unrealircd.allow -}}
{{ range . }}
allow {
  {{ if (.ip) -}}
  ip {{ .ip }};
  {{ else if (.hostname) -}}
  hostname {{ .hostname | quote }};
  {{- end }}
  class {{ .class }};
  maxperip {{ .maxperip }};
  {{ if .options -}}
  options {
    {{ range .options -}}
    {{ . }};
    {{- end }}
  };
  {{- end }}
};
{{ end }}
{{- end }}

log "/usr/lib64/unrealircd/logs/ircd.log" {
  maxsize 5MB;
  flags {
    errors;
    kills;
    tkl;
    connects;
    server-connects;
    oper;
    sadmin-commands;
    chg-commands;
    oper-override;
    spamfilter;
  };
};

{{ with .Values.unrealircd.listen }}
{{ range . }}
listen {
  ip {{ .ip }};
  port {{ .port }};
  {{ if .options -}}
  options {
    {{ range .options -}}
    {{ . }};
    {{- end }}
  };
  {{- end }}
  {{ if .ssl_options -}}
  ssl-options {
    options {
      {{ range .ssl_options -}}
      {{ . }};
      {{- end }}
    };
  };
  {{- end }}
};
{{ end }}
{{ end }}

/* Network configuration */
{{- with .Values.unrealircd.network_config }}
set {
{{- range $key, $val := . }}
  {{ if eq (kindOf $val) "map" }}
  {{ $key }} {
    {{- range $k, $v := $val }}
    {{ $k }} {{ $v | quote }};
    {{ end -}}
  };
  {{- else if eq (kindOf $val) "slice" }}
  {{ $key }} {
    {{ range $val -}}
    {{ . | quote }};
    {{ end }}
  };
  {{ else -}}
  {{ $key }} {{ $val | quote }};
  {{- end }}
{{ end -}}
};
{{ end }}

/* Server specific configuration */
{{ with .Values.unrealircd.server_config }}
set {
  kline-address       {{ .kline_address | quote }};
  modes-on-connect    {{ .modes_on_connect | quote }};
  modes-on-oper       {{ .modes_on_oper | quote}};
  snomask-on-oper     {{ .snomask_on_oper | quote}};
  oper-auto-join      {{ .oper_auto_join | quote }};
  options {
    {{ range .options -}}
    {{ . }};
    {{ end -}}
  };

  maxchannelsperuser {{ .maxchannelsperuser}};
  anti-spam-quit-message-time {{ .anti_spam_quit_message_time}};

  oper-only-stats {{ .oper_only_stats | quote }};

  anti-flood {
    nick-flood {{ .anti_flood.nick_flood }};
  };
  {{ with .spamfilter }}
  spamfilter {
    ban-time {{ .ban_time }};
    ban-reason {{ .ban_reason | quote }};
    virus-help-channel {{ .virus_help_channel | quote }};
  };
  {{ end }}
};
{{ end }}

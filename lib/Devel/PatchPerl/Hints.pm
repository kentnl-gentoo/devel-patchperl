package Devel::PatchPerl::Hints;
BEGIN {
  $Devel::PatchPerl::Hints::VERSION = '0.26';
}

#ABSTRACT: replacement 'hints' files

use strict;
use warnings;
use MIME::Base64 qw[decode_base64];
use File::Spec;

our @ISA            = qw[Exporter];
our @EXPORT_OK      = qw[hint_file];

my %hints = (
'netbsd' =>
'IyBoaW50cy9uZXRic2Quc2gKIwojIFBsZWFzZSBjaGVjayB3aXRoIHBhY2thZ2VzQG5ldGJzZC5v
cmcgYmVmb3JlIG1ha2luZyBtb2RpZmljYXRpb25zCiMgdG8gdGhpcyBmaWxlLgoKY2FzZSAiJGFy
Y2huYW1lIiBpbgonJykKICAgIGFyY2huYW1lPWB1bmFtZSAtbWAtJHtvc25hbWV9CiAgICA7Owpl
c2FjCgojIE5ldEJTRCBrZWVwcyBkeW5hbWljIGxvYWRpbmcgZGwqKCkgZnVuY3Rpb25zIGluIC91
c3IvbGliL2NydDAubywKIyBzbyBDb25maWd1cmUgZG9lc24ndCBmaW5kIHRoZW0gKHVubGVzcyB5
b3UgYWJhbmRvbiB0aGUgbm0gc2NhbikuCiMgQWxzbywgTmV0QlNEIDAuOWEgd2FzIHRoZSBmaXJz
dCByZWxlYXNlIHRvIGludHJvZHVjZSBzaGFyZWQKIyBsaWJyYXJpZXMuCiMKY2FzZSAiJG9zdmVy
cyIgaW4KMC45fDAuOCopCgl1c2VkbD0iJHVuZGVmIgoJOzsKKikKCWNhc2UgYHVuYW1lIC1tYCBp
bgoJcG1heCkKCQkjIE5ldEJTRCAxLjMgYW5kIDEuMy4xIG9uIHBtYXggc2hpcHBlZCBhbiBgb2xk
JyBsZC5zbywKCQkjIHdoaWNoIHdpbGwgbm90IHdvcmsuCgkJY2FzZSAiJG9zdmVycyIgaW4KCQkx
LjN8MS4zLjEpCgkJCWRfZGxvcGVuPSR1bmRlZgoJCQk7OwoJCWVzYWMKCQk7OwoJZXNhYwoJaWYg
dGVzdCAtZiAvdXNyL2xpYmV4ZWMvbGQuZWxmX3NvOyB0aGVuCgkJIyBFTEYKCQlkX2Rsb3Blbj0k
ZGVmaW5lCgkJZF9kbGVycm9yPSRkZWZpbmUKCQljY2NkbGZsYWdzPSItRFBJQyAtZlBJQyAkY2Nj
ZGxmbGFncyIKCQlsZGRsZmxhZ3M9Ii0td2hvbGUtYXJjaGl2ZSAtc2hhcmVkICRsZGRsZmxhZ3Mi
CgkJcnBhdGhmbGFnPSItV2wsLXJwYXRoLCIKCQljYXNlICIkb3N2ZXJzIiBpbgoJCTEuWzAtNV0q
KQoJCQkjCgkJCSMgSW5jbHVkZSB0aGUgd2hvbGUgbGliZ2NjLmEgaW50byB0aGUgcGVybCBleGVj
dXRhYmxlCgkJCSMgc28gdGhhdCBjZXJ0YWluIHN5bWJvbHMgbmVlZGVkIGJ5IGxvYWRhYmxlIG1v
ZHVsZXMKCQkJIyBidWlsdCBhcyBDKysgb2JqZWN0cyAoX19laF9hbGxvYywgX19wdXJlX3ZpcnR1
YWwsCgkJCSMgZXRjLikgd2lsbCBhbHdheXMgYmUgZGVmaW5lZC4KCQkJIwoJCQljY2RsZmxhZ3M9
Ii1XbCwtd2hvbGUtYXJjaGl2ZSAtbGdjYyBcCgkJCQktV2wsLW5vLXdob2xlLWFyY2hpdmUgLVds
LC1FICRjY2RsZmxhZ3MiCgkJCTs7CgkJKikKCQkJY2NkbGZsYWdzPSItV2wsLUUgJGNjZGxmbGFn
cyIKCQkJOzsKCQllc2FjCgllbGlmIHRlc3QgLWYgL3Vzci9saWJleGVjL2xkLnNvOyB0aGVuCgkJ
IyBhLm91dAoJCWRfZGxvcGVuPSRkZWZpbmUKCQlkX2RsZXJyb3I9JGRlZmluZQoJCWNjY2RsZmxh
Z3M9Ii1EUElDIC1mUElDICRjY2NkbGZsYWdzIgoJCWxkZGxmbGFncz0iLUJzaGFyZWFibGUgJGxk
ZGxmbGFncyIKCQlycGF0aGZsYWc9Ii1SIgoJZWxzZQoJCWRfZGxvcGVuPSR1bmRlZgoJCXJwYXRo
ZmxhZz0KCWZpCgk7Owplc2FjCgojIG5ldGJzZCBoYWQgdGhlc2UgYnV0IHRoZXkgZG9uJ3QgcmVh
bGx5IHdvcmsgYXMgYWR2ZXJ0aXNlZCwgaW4gdGhlCiMgdmVyc2lvbnMgbGlzdGVkIGJlbG93LiAg
aWYgdGhleSBhcmUgZGVmaW5lZCwgdGhlbiB0aGVyZSBpc24ndCBhCiMgd2F5IHRvIG1ha2UgcGVy
bCBjYWxsIHNldHVpZCgpIG9yIHNldGdpZCgpLiAgaWYgdGhleSBhcmVuJ3QsIHRoZW4KIyAoJDws
ICQ+KSA9ICgkdSwgJHUpOyB3aWxsIHdvcmsgKHNhbWUgZm9yICQoLyQpKS4gIHRoaXMgaXMgYmVj
YXVzZQojIHlvdSBjYW4gbm90IGNoYW5nZSB0aGUgcmVhbCB1c2VyaWQgb2YgYSBwcm9jZXNzIHVu
ZGVyIDQuNEJTRC4KIyBuZXRic2QgZml4ZWQgdGhpcyBpbiAxLjMuMi4KY2FzZSAiJG9zdmVycyIg
aW4KMC45KnwxLlswMTJdKnwxLjN8MS4zLjEpCglkX3NldHJlZ2lkPSIkdW5kZWYiCglkX3NldHJl
dWlkPSIkdW5kZWYiCgk7Owplc2FjCmNhc2UgIiRvc3ZlcnMiIGluCjAuOSp8MS4qfDIuKnwzLip8
NC4qfDUuKikKCWRfZ2V0cHJvdG9lbnRfcj0iJHVuZGVmIgoJZF9nZXRwcm90b2J5bmFtZV9yPSIk
dW5kZWYiCglkX2dldHByb3RvYnludW1iZXJfcj0iJHVuZGVmIgoJZF9zZXRwcm90b2VudF9yPSIk
dW5kZWYiCglkX2VuZHByb3RvZW50X3I9IiR1bmRlZiIKCWRfZ2V0c2VydmVudF9yPSIkdW5kZWYi
CglkX2dldHNlcnZieW5hbWVfcj0iJHVuZGVmIgoJZF9nZXRzZXJ2Ynlwb3J0X3I9IiR1bmRlZiIK
CWRfc2V0c2VydmVudF9yPSIkdW5kZWYiCglkX2VuZHNlcnZlbnRfcj0iJHVuZGVmIgoJZF9nZXRw
cm90b2VudF9yX3Byb3RvPSIwIgoJZF9nZXRwcm90b2J5bmFtZV9yX3Byb3RvPSIwIgoJZF9nZXRw
cm90b2J5bnVtYmVyX3JfcHJvdG89IjAiCglkX3NldHByb3RvZW50X3JfcHJvdG89IjAiCglkX2Vu
ZHByb3RvZW50X3JfcHJvdG89IjAiCglkX2dldHNlcnZlbnRfcl9wcm90bz0iMCIKCWRfZ2V0c2Vy
dmJ5bmFtZV9yX3Byb3RvPSIwIgoJZF9nZXRzZXJ2Ynlwb3J0X3JfcHJvdG89IjAiCglkX3NldHNl
cnZlbnRfcl9wcm90bz0iMCIKCWRfZW5kc2VydmVudF9yX3Byb3RvPSIwIgoJOzsKZXNhYwoKIyBU
aGVzZSBhcmUgb2Jzb2xldGUgaW4gYW55IG5ldGJzZC4KZF9zZXRyZ2lkPSIkdW5kZWYiCmRfc2V0
cnVpZD0iJHVuZGVmIgoKIyB0aGVyZSdzIG5vIHByb2JsZW0gd2l0aCB2Zm9yay4KdXNldmZvcms9
dHJ1ZQoKIyBUaGlzIGlzIHRoZXJlIGJ1dCBpbiBtYWNoaW5lL2llZWVmcF9oLgppZWVlZnBfaD0i
ZGVmaW5lIgoKIyBUaGlzIHNjcmlwdCBVVS91c2V0aHJlYWRzLmNidSB3aWxsIGdldCAnY2FsbGVk
LWJhY2snIGJ5IENvbmZpZ3VyZQojIGFmdGVyIGl0IGhhcyBwcm9tcHRlZCB0aGUgdXNlciBmb3Ig
d2hldGhlciB0byB1c2UgdGhyZWFkcy4KY2F0ID4gVVUvdXNldGhyZWFkcy5jYnUgPDwnRU9DQlUn
CmNhc2UgIiR1c2V0aHJlYWRzIiBpbgokZGVmaW5lfHRydWV8W3lZXSopCglscHRocmVhZD0KCWZv
ciB4eHggaW4gcHRocmVhZDsgZG8KCQlmb3IgeXl5IGluICRsb2NsaWJwdGggJHBsaWJwdGggJGds
aWJwdGggZHVtbXk7IGRvCgkJCXp6ej0keXl5L2xpYiR4eHguYQoJCQlpZiB0ZXN0IC1mICIkenp6
IjsgdGhlbgoJCQkJbHB0aHJlYWQ9JHh4eAoJCQkJYnJlYWs7CgkJCWZpCgkJCXp6ej0keXl5L2xp
YiR4eHguc28KCQkJaWYgdGVzdCAtZiAiJHp6eiI7IHRoZW4KCQkJCWxwdGhyZWFkPSR4eHgKCQkJ
CWJyZWFrOwoJCQlmaQoJCQl6eno9YGxzICR5eXkvbGliJHh4eC5zby4qIDI+L2Rldi9udWxsYAoJ
CQlpZiB0ZXN0ICJYJHp6eiIgIT0gWDsgdGhlbgoJCQkJbHB0aHJlYWQ9JHh4eAoJCQkJYnJlYWs7
CgkJCWZpCgkJZG9uZQoJCWlmIHRlc3QgIlgkbHB0aHJlYWQiICE9IFg7IHRoZW4KCQkJYnJlYWs7
CgkJZmkKCWRvbmUKCWlmIHRlc3QgIlgkbHB0aHJlYWQiICE9IFg7IHRoZW4KCQkjIEFkZCAtbHB0
aHJlYWQuCgkJbGlic3dhbnRlZD0iJGxpYnN3YW50ZWQgJGxwdGhyZWFkIgoJCSMgVGhlcmUgaXMg
bm8gbGliY19yIGFzIG9mIE5ldEJTRCAxLjUuMiwgc28gbm8gYyAtPiBjX3IuCgkJIyBUaGlzIHdp
bGwgYmUgcmV2aXNpdGVkIHdoZW4gTmV0QlNEIGdhaW5zIGEgbmF0aXZlIHB0aHJlYWRzCgkJIyBp
bXBsZW1lbnRhdGlvbi4KCWVsc2UKCQllY2hvICIkMDogTm8gUE9TSVggdGhyZWFkcyBsaWJyYXJ5
ICgtbHB0aHJlYWQpIGZvdW5kLiAgIiBcCgkJICAgICAiWW91IG1heSB3YW50IHRvIGluc3RhbGwg
R05VIHB0aC4gIEFib3J0aW5nLiIgPiY0CgkJZXhpdCAxCglmaQoJdW5zZXQgbHB0aHJlYWQKCgkj
IHNldmVyYWwgcmVlbnRyYW50IGZ1bmN0aW9ucyBhcmUgZW1iZWRkZWQgaW4gbGliYywgYnV0IGhh
dmVuJ3QKCSMgYmVlbiBhZGRlZCB0byB0aGUgaGVhZGVyIGZpbGVzIHlldC4gIExldCdzIGhvbGQg
b2ZmIG9uIHVzaW5nCgkjIHRoZW0gdW50aWwgdGhleSBhcmUgYSB2YWxpZCBwYXJ0IG9mIHRoZSBB
UEkKCWNhc2UgIiRvc3ZlcnMiIGluCglbMDEyXS4qfDMuWzAtMV0pCgkJZF9nZXRwcm90b2J5bmFt
ZV9yPSR1bmRlZgoJCWRfZ2V0cHJvdG9ieW51bWJlcl9yPSR1bmRlZgoJCWRfZ2V0cHJvdG9lbnRf
cj0kdW5kZWYKCQlkX2dldHNlcnZieW5hbWVfcj0kdW5kZWYKCQlkX2dldHNlcnZieXBvcnRfcj0k
dW5kZWYKCQlkX2dldHNlcnZlbnRfcj0kdW5kZWYKCQlkX3NldHByb3RvZW50X3I9JHVuZGVmCgkJ
ZF9zZXRzZXJ2ZW50X3I9JHVuZGVmCgkJZF9lbmRwcm90b2VudF9yPSR1bmRlZgoJCWRfZW5kc2Vy
dmVudF9yPSR1bmRlZiA7OwoJZXNhYwoJOzsKCmVzYWMKRU9DQlUKCiMgU2V0IHNlbnNpYmxlIGRl
ZmF1bHRzIGZvciBOZXRCU0Q6IGxvb2sgZm9yIGxvY2FsIHNvZnR3YXJlIGluCiMgL3Vzci9wa2cg
KE5ldEJTRCBQYWNrYWdlcyBDb2xsZWN0aW9uKSBhbmQgaW4gL3Vzci9sb2NhbC4KIwpsb2NsaWJw
dGg9Ii91c3IvcGtnL2xpYiAvdXNyL2xvY2FsL2xpYiIKbG9jaW5jcHRoPSIvdXNyL3BrZy9pbmNs
dWRlIC91c3IvbG9jYWwvaW5jbHVkZSIKY2FzZSAiJHJwYXRoZmxhZyIgaW4KJycpCglsZGZsYWdz
PQoJOzsKKikKCWxkZmxhZ3M9Cglmb3IgeXl5IGluICRsb2NsaWJwdGg7IGRvCgkJbGRmbGFncz0i
JGxkZmxhZ3MgJHJwYXRoZmxhZyR5eXkiCglkb25lCgk7Owplc2FjCgpjYXNlIGB1bmFtZSAtbWAg
aW4KYWxwaGEpCiAgICBlY2hvICdpbnQgbWFpbigpIHt9JyA+IHRyeS5jCiAgICBnY2M9YCR7Y2M6
LWNjfSAtdiAtYyB0cnkuYyAyPiYxfGdyZXAgJ2djYyB2ZXJzaW9uIGVnY3MtMidgCiAgICBjYXNl
ICIkZ2NjIiBpbgogICAgJycgfCAiZ2NjIHZlcnNpb24gZWdjcy0yLjk1LiJbMy05XSopIDs7ICMg
Mi45NS4zIG9yIGJldHRlciBva2F5CiAgICAqKQljYXQgPiY0IDw8RU9GCioqKgoqKiogWW91ciBn
Y2MgKCRnY2MpIGlzIGtub3duIHRvIGJlCioqKiB0b28gYnVnZ3kgb24gbmV0YnNkL2FscGhhIHRv
IGNvbXBpbGUgUGVybCB3aXRoIG9wdGltaXphdGlvbi4KKioqIEl0IGlzIHN1Z2dlc3RlZCB5b3Ug
aW5zdGFsbCB0aGUgbGFuZy9nY2MgcGFja2FnZSB3aGljaCBzaG91bGQKKioqIGhhdmUgYXQgbGVh
c3QgZ2NjIDIuOTUuMyB3aGljaCBzaG91bGQgd29yayBva2F5OiB1c2UgZm9yIGV4YW1wbGUKKioq
IENvbmZpZ3VyZSAtRGNjPS91c3IvcGtnL2djYy0yLjk1LjMvYmluL2NjLiAgWW91IGNvdWxkIGFs
c28KKioqIENvbmZpZ3VyZSAtRG9wdGltaXplPS1PMCB0byBjb21waWxlIFBlcmwgd2l0aG91dCBh
bnkgb3B0aW1pemF0aW9uCioqKiBidXQgdGhhdCBpcyBub3QgcmVjb21tZW5kZWQuCioqKgpFT0YK
CWV4aXQgMQoJOzsKICAgIGVzYWMKICAgIHJtIC1mIHRyeS4qCiAgICA7Owplc2FjCgojIE5ldEJT
RC9zcGFyYyAxLjUuMy8xLjYuMSBkdW1wcyBjb3JlIGluIHRoZSBzZW1pZF9kcyB0ZXN0IG9mIENv
bmZpZ3VyZS4KY2FzZSBgdW5hbWUgLW1gIGluCnNwYXJjKSBkX3NlbWN0bF9zZW1pZF9kcz11bmRl
ZiA7Owplc2FjCgojIG1hbGxvYyB3cmFwIHdvcmtzCmNhc2UgIiR1c2VtYWxsb2N3cmFwIiBpbgon
JykgdXNlbWFsbG9jd3JhcD0nZGVmaW5lJyA7Owplc2FjCgojIGRvbid0IHVzZSBwZXJsIG1hbGxv
YyBieSBkZWZhdWx0CmNhc2UgIiR1c2VteW1hbGxvYyIgaW4KJycpIHVzZW15bWFsbG9jPW4gOzsK
ZXNhYwo=',
'freebsd' =>
'IyBPcmlnaW5hbCBiYXNlZCBvbiBpbmZvIGZyb20KIyBDYXJsIE0uIEZvbmdoZWlzZXIgPGNtZkBp
bnMuaW5mb25ldC5uZXQ+CiMgRGF0ZTogVGh1LCAyOCBKdWwgMTk5NCAxOToxNzowNSAtMDUwMCAo
Q0RUKQojCiMgQWRkaXRpb25hbCAxLjEuNSBkZWZpbmVzIGZyb20gCiMgT2xsaXZpZXIgUm9iZXJ0
IDxPbGxpdmllci5Sb2JlcnRAa2VsdGlhLmZybXVnLmZyLm5ldD4KIyBEYXRlOiBXZWQsIDI4IFNl
cCAxOTk0IDAwOjM3OjQ2ICswMTAwIChNRVQpCiMKIyBBZGRpdGlvbmFsIDIuKiBkZWZpbmVzIGZy
b20KIyBPbGxpdmllciBSb2JlcnQgPE9sbGl2aWVyLlJvYmVydEBrZWx0aWEuZnJtdWcuZnIubmV0
PgojIERhdGU6IFNhdCwgOCBBcHIgMTk5NSAyMDo1Mzo0MSArMDIwMCAoTUVUIERTVCkKIwojIEFk
ZGl0aW9uYWwgMi4wLjUgYW5kIDIuMSBkZWZpbmVkIGZyb20KIyBPbGxpdmllciBSb2JlcnQgPE9s
bGl2aWVyLlJvYmVydEBrZWx0aWEuZnJtdWcuZnIubmV0PgojIERhdGU6IEZyaSwgMTIgTWF5IDE5
OTUgMTQ6MzA6MzggKzAyMDAgKE1FVCBEU1QpCiMKIyBBZGRpdGlvbmFsIDIuMiBkZWZpbmVzIGZy
b20KIyBNYXJrIE11cnJheSA8bWFya0Bncm9uZGFyLnphPgojIERhdGU6IFdlZCwgNiBOb3YgMTk5
NiAwOTo0NDo1OCArMDIwMCAoTUVUKQojCiMgTW9kaWZpZWQgdG8gZW5zdXJlIHdlIHJlcGxhY2Ug
LWxjIHdpdGggLWxjX3IsIGFuZAojIHRvIHB1dCBpbiBwbGFjZS1ob2xkZXJzIGZvciB2YXJpb3Vz
IHNwZWNpZmljIGhpbnRzLgojIEFuZHkgRG91Z2hlcnR5IDxkb3VnaGVyYUBsYWZheWV0dGUuZWR1
PgojIERhdGU6IFR1ZSBNYXIgMTAgMTY6MDc6MDAgRVNUIDE5OTgKIwojIFN1cHBvcnQgZm9yIEZy
ZWVCU0QvRUxGCiMgT2xsaXZpZXIgUm9iZXJ0IDxyb2JlcnRvQGtlbHRpYS5mcmVlbml4LmZyPgoj
IERhdGU6IFdlZCBTZXAgIDIgMTY6MjI6MTIgQ0VTVCAxOTk4CiMKIyBUaGUgdHdvIGZsYWdzICIt
ZnBpYyAtRFBJQyIgYXJlIHVzZWQgdG8gaW5kaWNhdGUgYQojIHdpbGwtYmUtc2hhcmVkIG9iamVj
dC4gIENvbmZpZ3VyZSB3aWxsIGd1ZXNzIHRoZSAtZnBpYywgKGFuZCB0aGUKIyAtRFBJQyBpcyBu
b3QgdXNlZCBieSBwZXJsIHByb3BlcikgYnV0IHRoZSBmdWxsIGRlZmluZSBpcyBpbmNsdWRlZCB0
byAKIyBiZSBjb25zaXN0ZW50IHdpdGggdGhlIEZyZWVCU0QgZ2VuZXJhbCBzaGFyZWQgbGlicyBi
dWlsZGluZyBwcm9jZXNzLgojCiMgc2V0cmV1aWQgYW5kIGZyaWVuZHMgYXJlIGluaGVyZW50bHkg
YnJva2VuIGluIGFsbCB2ZXJzaW9ucyBvZiBGcmVlQlNECiMgYmVmb3JlIDIuMS1jdXJyZW50IChi
ZWZvcmUgYXBwcm94IGRhdGUgNC8xNS85NSkuIEl0IGlzIGZpeGVkIGluIDIuMC41CiMgYW5kIHdo
YXQtd2lsbC1iZS0yLjEKIwoKY2FzZSAiJG9zdmVycyIgaW4KMC4qfDEuMCopCgl1c2VkbD0iJHVu
ZGVmIgoJOzsKMS4xKikKCW1hbGxvY3R5cGU9J3ZvaWQgKicKCWdyb3Vwc3R5cGU9J2ludCcKCWRf
c2V0cmVnaWQ9J3VuZGVmJwoJZF9zZXRyZXVpZD0ndW5kZWYnCglkX3NldHJnaWQ9J3VuZGVmJwoJ
ZF9zZXRydWlkPSd1bmRlZicKCTs7CjIuMC1yZWxlYXNlKikKCWRfc2V0cmVnaWQ9J3VuZGVmJwoJ
ZF9zZXRyZXVpZD0ndW5kZWYnCglkX3NldHJnaWQ9J3VuZGVmJwoJZF9zZXRydWlkPSd1bmRlZicK
CTs7CiMKIyBUcnlpbmcgdG8gY292ZXIgMi4wLjUsIDIuMS1jdXJyZW50IGFuZCBmdXR1cmUgMi4x
LzIuMgojIEl0IGRvZXMgbm90IGNvdmVydCBhbGwgMi4xLWN1cnJlbnQgdmVyc2lvbnMgYXMgdGhl
IG91dHB1dCBvZiB1bmFtZQojIGNoYW5nZWQgYSBmZXcgdGltZXMuCiMKIyBFdmVuIHRob3VnaCBz
ZXRldWlkL3NldGVnaWQgYXJlIGF2YWlsYWJsZSwgdGhleSd2ZSBiZWVuIHR1cm5lZCBvZmYKIyBi
ZWNhdXNlIHBlcmwgaXNuJ3QgY29kZWQgd2l0aCBzYXZlZCBzZXRbdWddaWQgdmFyaWFibGVzIGlu
IG1pbmQuCiMgSW4gYWRkaXRpb24sIGEgc21hbGwgcGF0Y2ggaXMgcmVxdWlyZWQgdG8gc3VpZHBl
cmwgdG8gYXZvaWQgYSBzZWN1cml0eQojIHByb2JsZW0gd2l0aCBGcmVlQlNELgojCjIuMC41Knwy
LjAtYnVpbHQqfDIuMSopCiAJdXNldmZvcms9J3RydWUnCgljYXNlICIkdXNlbXltYWxsb2MiIGlu
CgkgICAgIiIpIHVzZW15bWFsbG9jPSduJwoJICAgICAgICA7OwoJZXNhYwoJZF9zZXRyZWdpZD0n
ZGVmaW5lJwoJZF9zZXRyZXVpZD0nZGVmaW5lJwoJZF9zZXRlZ2lkPSd1bmRlZicKCWRfc2V0ZXVp
ZD0ndW5kZWYnCgl0ZXN0IC1yIC4vYnJva2VuLWRiLm1zZyAmJiAuIC4vYnJva2VuLWRiLm1zZwoJ
OzsKIwojIDIuMiBhbmQgYWJvdmUgaGF2ZSBwaGttYWxsb2MoMykuCiMgZG9uJ3QgdXNlIC1sbWFs
bG9jIChtYXliZSB0aGVyZSdzIGFuIG9sZCBvbmUgZnJvbSAxLjEuNS4xIGZsb2F0aW5nIGFyb3Vu
ZCkKMi4yKikKIAl1c2V2Zm9yaz0ndHJ1ZScKCWNhc2UgIiR1c2VteW1hbGxvYyIgaW4KCSAgICAi
IikgdXNlbXltYWxsb2M9J24nCgkgICAgICAgIDs7Cgllc2FjCglsaWJzd2FudGVkPWBlY2hvICRs
aWJzd2FudGVkIHwgc2VkICdzLyBtYWxsb2MgLyAvJ2AKCWxpYnN3YW50ZWQ9YGVjaG8gJGxpYnN3
YW50ZWQgfCBzZWQgJ3MvIGJpbmQgLyAvJ2AKCSMgaWNvbnYgZ29uZSBpbiBQZXJsIDUuOC4xLCBi
dXQgaWYgc29tZW9uZSBjb21waWxlcyA1LjguMCBvciBlYXJsaWVyLgoJbGlic3dhbnRlZD1gZWNo
byAkbGlic3dhbnRlZCB8IHNlZCAncy8gaWNvbnYgLyAvJ2AKCWRfc2V0cmVnaWQ9J2RlZmluZScK
CWRfc2V0cmV1aWQ9J2RlZmluZScKCWRfc2V0ZWdpZD0nZGVmaW5lJwoJZF9zZXRldWlkPSdkZWZp
bmUnCgkjIGRfZG9zdWlkPSdkZWZpbmUnICMgT2Jzb2xldGUuCgk7OwoqKQl1c2V2Zm9yaz0ndHJ1
ZScKCWNhc2UgIiR1c2VteW1hbGxvYyIgaW4KCSAgICAiIikgdXNlbXltYWxsb2M9J24nCgkgICAg
ICAgIDs7Cgllc2FjCglsaWJzd2FudGVkPWBlY2hvICRsaWJzd2FudGVkIHwgc2VkICdzLyBtYWxs
b2MgLyAvJ2AKCTs7CmVzYWMKCiMgRHluYW1pYyBMb2FkaW5nIGZsYWdzIGhhdmUgbm90IGNoYW5n
ZWQgbXVjaCwgc28gdGhleSBhcmUgc2VwYXJhdGVkCiMgb3V0IGhlcmUgdG8gYXZvaWQgZHVwbGlj
YXRpbmcgdGhlbSBldmVyeXdoZXJlLgpjYXNlICIkb3N2ZXJzIiBpbgowLip8MS4wKikgOzsKCjEq
fDIqKQljY2NkbGZsYWdzPSctRFBJQyAtZnBpYycKCWxkZGxmbGFncz0iLUJzaGFyZWFibGUgJGxk
ZGxmbGFncyIKCTs7CgozKnw0Knw1Knw2KikKICAgICAgICBvYmpmb3JtYXQ9YC91c3IvYmluL29i
amZvcm1hdGAKICAgICAgICBpZiBbIHgkb2JqZm9ybWF0ID0geGFvdXQgXTsgdGhlbgogICAgICAg
ICAgICBpZiBbIC1lIC91c3IvbGliL2FvdXQgXTsgdGhlbgogICAgICAgICAgICAgICAgbGlicHRo
PSIvdXNyL2xpYi9hb3V0IC91c3IvbG9jYWwvbGliIC91c3IvbGliIgogICAgICAgICAgICAgICAg
Z2xpYnB0aD0iL3Vzci9saWIvYW91dCAvdXNyL2xvY2FsL2xpYiAvdXNyL2xpYiIKICAgICAgICAg
ICAgZmkKICAgICAgICAgICAgbGRkbGZsYWdzPSctQnNoYXJlYWJsZScKICAgICAgICBlbHNlCiAg
ICAgICAgICAgIGxpYnB0aD0iL3Vzci9saWIgL3Vzci9sb2NhbC9saWIiCiAgICAgICAgICAgIGds
aWJwdGg9Ii91c3IvbGliIC91c3IvbG9jYWwvbGliIgogICAgICAgICAgICBsZGZsYWdzPSItV2ws
LUUgIgogICAgICAgICAgICBsZGRsZmxhZ3M9Ii1zaGFyZWQgIgogICAgICAgIGZpCiAgICAgICAg
Y2NjZGxmbGFncz0nLURQSUMgLWZQSUMnCiAgICAgICAgOzsKKikKICAgICAgIGxpYnB0aD0iL3Vz
ci9saWIgL3Vzci9sb2NhbC9saWIiCiAgICAgICBnbGlicHRoPSIvdXNyL2xpYiAvdXNyL2xvY2Fs
L2xpYiIKICAgICAgIGxkZmxhZ3M9Ii1XbCwtRSAiCiAgICAgICAgbGRkbGZsYWdzPSItc2hhcmVk
ICIKICAgICAgICBjY2NkbGZsYWdzPSctRFBJQyAtZlBJQycKICAgICAgIDs7CmVzYWMKCmNhc2Ug
IiRvc3ZlcnMiIGluCjAqfDEqfDIqfDMqKSA7OwoKKikKCWNjZmxhZ3M9IiR7Y2NmbGFnc30gLURI
QVNfRlBTRVRNQVNLIC1ESEFTX0ZMT0FUSU5HUE9JTlRfSCIKCWlmIC91c3IvYmluL2ZpbGUgLUwg
L3Vzci9saWIvbGliYy5zbyB8IC91c3IvYmluL2dyZXAgLXZxICJub3Qgc3RyaXBwZWQiIDsgdGhl
bgoJICAgIHVzZW5tPWZhbHNlCglmaQogICAgICAgIDs7CmVzYWMKCmNhdCA8PCdFT00nID4mNAoK
U29tZSB1c2VycyBoYXZlIHJlcG9ydGVkIHRoYXQgQ29uZmlndXJlIGhhbHRzIHdoZW4gdGVzdGlu
ZyBmb3IKdGhlIE9fTk9OQkxPQ0sgc3ltYm9sIHdpdGggYSBzeW50YXggZXJyb3IuICBUaGlzIGlz
IGFwcGFyZW50bHkgYQpzaCBlcnJvci4gIFJlcnVubmluZyBDb25maWd1cmUgd2l0aCBrc2ggYXBw
YXJlbnRseSBmaXhlcyB0aGUKcHJvYmxlbS4gIFRyeQoJa3NoIENvbmZpZ3VyZSBbeW91ciBvcHRp
b25zXQoKRU9NCgojIEZyb206IEFudG9uIEJlcmV6aW4gPHRvYmV6QHBsYWIua3UuZGs+CiMgVG86
IHBlcmw1LXBvcnRlcnNAcGVybC5vcmcKIyBTdWJqZWN0OiBbUEFUQ0ggNS4wMDVfNTRdIENvbmZp
Z3VyZSAtIGhpbnRzL2ZyZWVic2Quc2ggc2lnbmFsIGhhbmRsZXIgdHlwZQojIERhdGU6IDMwIE5v
diAxOTk4IDE5OjQ2OjI0ICswMTAwCiMgTWVzc2FnZS1JRDogPDg2NHNyaGh2Y3YuZnNmQGxpb24u
cGxhYi5rdS5kaz4KCnNpZ25hbF90PSd2b2lkJwpkX3ZvaWRzaWc9J2RlZmluZScKCiMgc2V0IGxp
YnBlcmwuc28uWC5YIGZvciAyLjIuWApjYXNlICIkb3N2ZXJzIiBpbgoyLjIqKQogICAgIyB1bmZv
cnR1bmF0ZWx5IHRoaXMgY29kZSBnZXRzIGV4ZWN1dGVkIGJlZm9yZQogICAgIyB0aGUgZXF1aXZh
bGVudCBpbiB0aGUgbWFpbiBDb25maWd1cmUgc28gd2UgY29weSBhIGxpdHRsZQogICAgIyBmcm9t
IENvbmZpZ3VyZSBYWFggQ29uZmlndXJlIHNob3VsZCBiZSBmaXhlZC4KICAgIGlmICR0ZXN0IC1y
ICRzcmMvcGF0Y2hsZXZlbC5oO3RoZW4KICAgICAgIHBhdGNobGV2ZWw9YGF3ayAnL2RlZmluZVsg
CV0rUEVSTF9WRVJTSU9OLyB7cHJpbnQgJDN9JyAkc3JjL3BhdGNobGV2ZWwuaGAKICAgICAgIHN1
YnZlcnNpb249YGF3ayAnL2RlZmluZVsgCV0rUEVSTF9TVUJWRVJTSU9OLyB7cHJpbnQgJDN9JyAk
c3JjL3BhdGNobGV2ZWwuaGAKICAgIGVsc2UKICAgICAgIHBhdGNobGV2ZWw9MAogICAgICAgc3Vi
dmVyc2lvbj0wCiAgICBmaQogICAgbGlicGVybD0ibGlicGVybC5zby4kcGF0Y2hsZXZlbC4kc3Vi
dmVyc2lvbiIKICAgIHVuc2V0IHBhdGNobGV2ZWwKICAgIHVuc2V0IHN1YnZlcnNpb24KICAgIDs7
CmVzYWMKCiMgVGhpcyBzY3JpcHQgVVUvdXNldGhyZWFkcy5jYnUgd2lsbCBnZXQgJ2NhbGxlZC1i
YWNrJyBieSBDb25maWd1cmUgCiMgYWZ0ZXIgaXQgaGFzIHByb21wdGVkIHRoZSB1c2VyIGZvciB3
aGV0aGVyIHRvIHVzZSB0aHJlYWRzLgpjYXQgPiBVVS91c2V0aHJlYWRzLmNidSA8PCdFT0NCVScK
Y2FzZSAiJHVzZXRocmVhZHMiIGluCiRkZWZpbmV8dHJ1ZXxbeVldKikKICAgICAgICBsY19yPWAv
c2Jpbi9sZGNvbmZpZyAtcnxncmVwICc6LWxjX3InfGF3ayAne3ByaW50ICRORn0nfHNlZCAtbiAn
JHAnYAogICAgICAgIGNhc2UgIiRvc3ZlcnMiIGluICAKCTAqfDEqfDIuMCp8Mi4xKikgICBjYXQg
PDxFT00gPiY0CkkgZGlkIG5vdCBrbm93IHRoYXQgRnJlZUJTRCAkb3N2ZXJzIHN1cHBvcnRzIFBP
U0lYIHRocmVhZHMuCgpGZWVsIGZyZWUgdG8gdGVsbCBwZXJsYnVnQHBlcmwub3JnIG90aGVyd2lz
ZS4KRU9NCgkgICAgICBleGl0IDEKCSAgICAgIDs7CgogICAgICAgIDIuMi5bMC03XSopCiAgICAg
ICAgICAgICAgY2F0IDw8RU9NID4mNApQT1NJWCB0aHJlYWRzIGFyZSBub3Qgc3VwcG9ydGVkIHdl
bGwgYnkgRnJlZUJTRCAkb3N2ZXJzLgoKUGxlYXNlIGNvbnNpZGVyIHVwZ3JhZGluZyB0byBhdCBs
ZWFzdCBGcmVlQlNEIDIuMi44LApvciBwcmVmZXJhYmx5IHRvIHRoZSBtb3N0IHJlY2VudCAtUkVM
RUFTRSBvciAtU1RBQkxFCnZlcnNpb24gKHNlZSBodHRwOi8vd3d3LmZyZWVic2Qub3JnL3JlbGVh
c2VzLykuCgooV2hpbGUgMi4yLjcgZG9lcyBoYXZlIHB0aHJlYWRzLCBpdCBoYXMgc29tZSBwcm9i
bGVtcwogd2l0aCB0aGUgY29tYmluYXRpb24gb2YgdGhyZWFkcyBhbmQgcGlwZXMgYW5kIHRoZXJl
Zm9yZQogbWFueSBQZXJsIHRlc3RzIHdpbGwgZWl0aGVyIGhhbmcgb3IgZmFpbC4pCkVPTQoJICAg
ICAgZXhpdCAxCgkgICAgICA7OwoKCVszLTVdLiopCgkgICAgICBpZiBbICEgLXIgIiRsY19yIiBd
OyB0aGVuCgkgICAgICBjYXQgPDxFT00gPiY0ClBPU0lYIHRocmVhZHMgc2hvdWxkIGJlIHN1cHBv
cnRlZCBieSBGcmVlQlNEICRvc3ZlcnMgLS0KYnV0IHlvdXIgc3lzdGVtIGlzIG1pc3NpbmcgdGhl
IHNoYXJlZCBsaWJjX3IuCigvc2Jpbi9sZGNvbmZpZyAtciBkb2Vzbid0IGZpbmQgYW55KS4KCkNv
bnNpZGVyIHVzaW5nIHRoZSBsYXRlc3QgU1RBQkxFIHJlbGVhc2UuCkVPTQoJCSBleGl0IDEKCSAg
ICAgIGZpCgkgICAgICAjIDUwMDAxNiBpcyB0aGUgZmlyc3Qgb3NyZWxkYXRlIGluIHdoaWNoIG9u
ZSBjb3VsZAoJICAgICAgIyBqdXN0IGxpbmsgYWdhaW5zdCBsaWJjX3Igd2l0aG91dCBkaXNwb3Np
bmcgb2YgbGliYwoJICAgICAgIyBhdCB0aGUgc2FtZSB0aW1lLiAgNTAwMDE2IC4uLiB1cCB0byB3
aGF0ZXZlciBpdCB3YXMKCSAgICAgICMgb24gdGhlIDMxc3Qgb2YgQXVndXN0IDIwMDMgY2FuIHN0
aWxsIGJlIHVzZWQgd2l0aCAtcHRocmVhZCwKCSAgICAgICMgYnV0IGl0IGlzIG5vdCBuZWNlc3Nh
cnkuCgoJICAgICAgIyBBbnRvbiBCZXJlemluIHNheXMgdGhhdCBwb3N0IDUwMHNvbWV0aGluZyB3
ZSdyZSB3cm9uZyB0byBiZQoJICAgICAgIyB0byBiZSB1c2luZyAtbGNfciwgYW5kIHNob3VsZCBq
dXN0IGJlIHVzaW5nIC1wdGhyZWFkIG9uIHRoZQoJICAgICAgIyBsaW5rZXIgbGluZS4KCSAgICAg
ICMgU28gcHJlc3VtYWJseSByZWFsbHkgd2Ugc2hvdWxkIGJlIGNoZWNraW5nIHRoYXQgJG9zdmVy
IGlzIDUuKikKCSAgICAgICMgYW5kIHRoYXQgYC9zYmluL3N5c2N0bCAtbiBrZXJuLm9zcmVsZGF0
ZWAgLWdlIDUwMDAxNgoJICAgICAgIyBvciAtbHQgNTAwc29tZXRoaW5nIGFuZCBvbmx5IGluIHRo
YXQgcmFuZ2Ugbm90IGRvaW5nIHRoaXM6CgkgICAgICBsZGZsYWdzPSItcHRocmVhZCAkbGRmbGFn
cyIKCgkgICAgICAjIEJvdGggaW4gNC54IGFuZCA1LnggZ2V0aG9zdGJ5YWRkcl9yIGV4aXN0cyBi
dXQKCSAgICAgICMgaXQgaXMgIlRlbXBvcmFyeSBmdW5jdGlvbiwgbm90IHRocmVhZHNhZmUiLi4u
CgkgICAgICAjIFByZXN1bWFibHkgZWFybGllciBpdCBkaWRuJ3QgZXZlbiBleGlzdC4KCSAgICAg
IGRfZ2V0aG9zdGJ5YWRkcl9yPSJ1bmRlZiIKCSAgICAgIGRfZ2V0aG9zdGJ5YWRkcl9yX3Byb3Rv
PSIwIgoJICAgICAgOzsKCgkqKQoJICAgICAgIyA3LnggZG9lc24ndCBpbnN0YWxsIGxpYmNfciBi
eSBkZWZhdWx0LCBhbmQgQ29uZmlndXJlCgkgICAgICAjIHdvdWxkIGZhaWwgaW4gdGhlIGNvZGUg
Zm9sbG93aW5nCgkgICAgICAjCgkgICAgICAjIGdldGhvc3RieWFkZHJfcigpIGFwcGVhcnMgdG8g
aGF2ZSBiZWVuIGltcGxlbWVudGVkIGluIDYueCsKCSAgICAgIGxkZmxhZ3M9Ii1wdGhyZWFkICRs
ZGZsYWdzIgoJICAgICAgOzsKCgllc2FjCgogICAgICAgIGNhc2UgIiRvc3ZlcnMiIGluCiAgICAg
ICAgWzEtNF0qKQoJICAgIHNldCBgZWNobyBYICIkbGlic3dhbnRlZCAifCBzZWQgLWUgJ3MvIGMg
LyBjX3IgLydgCgkgICAgc2hpZnQKCSAgICBsaWJzd2FudGVkPSIkKiIKCSAgICA7OwogICAgICAg
ICopCgkgICAgc2V0IGBlY2hvIFggIiRsaWJzd2FudGVkICJ8IHNlZCAtZSAncy8gYyAvLydgCgkg
ICAgc2hpZnQKCSAgICBsaWJzd2FudGVkPSIkKiIKCSAgICA7OwoJZXNhYwoJICAgIAoJIyBDb25m
aWd1cmUgd2lsbCBwcm9iYWJseSBwaWNrIHRoZSB3cm9uZyBsaWJjIHRvIHVzZSBmb3Igbm0gc2Nh
bi4KCSMgVGhlIHNhZmVzdCBxdWljay1maXggaXMganVzdCB0byBub3QgdXNlIG5tIGF0IGFsbC4u
LgoJdXNlbm09ZmFsc2UKCiAgICAgICAgY2FzZSAiJG9zdmVycyIgaW4KICAgICAgICAyLjIuOCop
CiAgICAgICAgICAgICMgLi4uIGJ1dCB0aGlzIGRvZXMgbm90IGFwcGx5IGZvciAyLjIuOCAtIHdl
IGtub3cgaXQncyBzYWZlCiAgICAgICAgICAgIGxpYmM9IiRsY19yIgogICAgICAgICAgICB1c2Vu
bT10cnVlCiAgICAgICAgICAgOzsKICAgICAgICBlc2FjCgogICAgICAgIHVuc2V0IGxjX3IKCgkj
IEV2ZW4gd2l0aCB0aGUgbWFsbG9jIG11dGV4ZXMgdGhlIFBlcmwgbWFsbG9jIGRvZXMgbm90Cgkj
IHNlZW0gdG8gYmUgdGhyZWFkc2FmZSBpbiBGcmVlQlNEPwoJY2FzZSAiJHVzZW15bWFsbG9jIiBp
bgoJJycpIHVzZW15bWFsbG9jPW4gOzsKCWVzYWMKZXNhYwpFT0NCVQoKIyBtYWxsb2Mgd3JhcCB3
b3JrcwpjYXNlICIkdXNlbWFsbG9jd3JhcCIgaW4KJycpIHVzZW1hbGxvY3dyYXA9J2RlZmluZScg
OzsKZXNhYwoKIyBYWFggVW5kZXIgRnJlZUJTRCA2LjAgKGFuZCBwcm9iYWJseSBtb3N0IG90aGVy
IHNpbWlsYXIgdmVyc2lvbnMpCiMgUGVybF9kaWUoTlVMTCkgZ2VuZXJhdGVzIGEgd2FybmluZzoK
IyAgICBwcF9zeXMuYzo0OTE6IHdhcm5pbmc6IG51bGwgZm9ybWF0IHN0cmluZwojIENvbmZpZ3Vy
ZSBzdXBwb3NlZGVseSB0ZXN0cyBmb3IgdGhpcywgYnV0IGFwcGFyZW50bHkgdGhlIHRlc3QgZG9l
c24ndAojIHdvcmsuICBWb2x1bnRlZXJzIHdpdGggRnJlZUJTRCBhcmUgbmVlZGVkIHRvIGltcHJv
dmluZyB0aGUgQ29uZmlndXJlIHRlc3QuCiMgTWVhbndoaWxlLCB0aGUgZm9sbG93aW5nIHdvcmth
cm91bmQgc2hvdWxkIGJlIHNhZmUgb24gYWxsIHZlcnNpb25zCiMgb2YgRnJlZUJTRC4KZF9wcmlu
dGZfZm9ybWF0X251bGw9J3VuZGVmJwo=',
);

my %files = (
  'freebsd' => 'freebsd.sh',
  'netbsd'  => 'netbsd.sh',
);

sub hint_file {
  my $os = shift;
  $os = shift if eval { $os->isa(__PACKAGE__) };
  $os = $^O unless $os;
  return unless defined $hints{ $os };
  my $content = decode_base64( $hints{ $os } );
  return $content unless wantarray;
  return ( $files{ $os }, $content );
}

qq'nudge nudge wink wink';


__END__
=pod

=head1 NAME

Devel::PatchPerl::Hints - replacement 'hints' files

=head1 VERSION

version 0.26

=head1 SYNOPSIS

  use Devel::PatchPerl::Hints;

  if ( my $content = Devel::PatchPerl::Hints->hint_file() ) {
    chmod 0755, 'hints/netbsd.sh' or die "$!";
    open my $hints, '>', 'hints/netbsd.sh' or die "$!";
    print $hints $content;
    close $hints;
  }

=head1 DESCRIPTION

Sometimes there is a problem with Perls C<hints> file for a particular
perl port. This module provides fixed C<hints> files encoded using
C<MIME::Base64>.

=head1 FUNCTION

The function is exported, but has to implicitly imported into the
requesting package.

  use Devel::PatchPerl::Hints qw[hint_file];

It may also be called as a class method:

  use Devel::PatchPerl::Hints;

  my $content = Devel::PatchPerl::Hints->hint_file();

=over

=item C<hint_file>

Takes an optional argument which is the OS name ( as would be returned by C<$^O> ).
By default it will use C<$^O>.

In a scalar context, Will return the decoded content of the C<hints> file suitable for writing straight to a
file handle or undef list if there isn't an applicable C<hints> file for the given or derived
OS.

If called in a list context, will return a list, the first item will be the name of the C<hints> file that
will need to be amended, the second item will be a string with the decoded content of the C<hints> file suitable
for writing straight to a file handle. Otherwise an empty list will be returned.

=back

=head1 AUTHOR

Chris Williams <chris@bingosnet.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Chris Williams and Marcus Holland-Moritz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


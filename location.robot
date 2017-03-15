*** Settings ***
Documentation    test the location directive in nginx
...    Almost all locations return the same string configured after location directive
...    In robot \ is an escape character, it requires escaping it with an other backslash like \\
Library             Collections
Library             OperatingSystem
Library             RequestsLibrary
Suite Setup         Start Nginx Or Reload Config
Suite Teardown      Run Keyword If    ${do_post}    Stop Nginx

*** Variables ***
${URL}=             http://127.0.0.1:88

*** Test Cases ***
URI Should Be Decoded
    [Documentation]    decoding the text encoded in the “%XX” form
    [Template]    Send Request And Verify Response
    /a b                        ~* /a\\Wb
    /a%20b                      ~* /a\\Wb

URI Should Be Resolved
    [Documentation]    resolving references to relative path
    [Template]    Send Request And Verify Response
    /home/./foo                 /home/foo
    /home//foo                  /home/foo
    /home///foo                 /home/foo
    /home/bar/../foo            /home/foo

The Longest Matching Prefix Is Used If No Regex matches
    [Tags]    prefix
    [Template]    Send Request And Verify Response
    ${EMPTY}                    /                   if uri is emtpy, the uri is / by default
    /home/fo                    /home               location /home is the prefix of uri /home/fo, but location /home/foo isn't
    /home/foo                   /home/foo
    /home/foo/                  /home/foo

The Longest Matching Prefix Is Used If It Has ^~ Modifier
    [Tags]    prefix
    [Template]    Send Request And Verify Response
    /etcet                       ^~ /etc

Case Sensitive
    [Documentation]    matching with prefix strings is case sensitive on linux.
    ...    For case-insensitive operating systems such as macOS and Cygwin,
    ...    matching with prefix strings ignores a case.
    ...    This test is run on linux
    [Template]    Send Request And Verify Response
    /home/Foo                   /home
    /home/FOO                   /home

Regex Match
    [Tags]    regex
    [Template]    Send Request And Verify Response
    /baz                        ~ baz
    /home/baz                   ~ baz
    /tmp/iambazille             ~ baz

Regex Match Case Insensitive
    [Tags]    regex
    [Template]    Send Request And Verify Response
    /insensitive                ~* ^/insensitive$
    /Insensitive                ~* ^/insensitive$
    /INSENSITIVE                ~* ^/insensitive$

Regex With Capture
    [Documentation]    Regular expressions can contain captures
    ...    that can later be used in other directives.
    ...    The first capture is $1
    [Tags]    regex
    [Template]    Send Request And Verify Response
    /dev/sda                    a:
    /dev/sda1                   a:1
    /dev/sdb9                   b:9
    /dev/Sda                    /

Exact Match
    [Documentation]    If an exact match is found, the search terminates
    [Tags]    prefix
    [Template]    Send Request And Verify Response
    /etc                        = /etc              ^~ /etc is before = /etc but exact match has highest privilege
    /eta                        ~ /et[a-z]
    /etcetera                   ~ /et[a-z]          longest matched location is /etcetera, but still search regex location

Nested Locations
    [Documentation]    If an exact match is found, the search terminates
    [Tags]    nested
    [Template]    Send Request And Verify Response
    /var                        /var
    /variable                   /varia
    /var1                       /var:1
    /var9                       /var:9

Special Redirect
    [Timeout]    1s
    ${resp}=    Send Request And Verify Response    /tmp    I am listening 8888
    Should Be Equal As Strings    ${resp.history[0].status_code}    301
    Dictionary Should Contain Item    ${resp.history[0].headers}    Location    ${URL}/tmp/


*** Keywords ***
Send Request And Verify Response
    [Documentation]    Request to http://127.0.0.1${uri} should be handled by location which returns ${body}
    [Arguments]    ${uri}    ${body}    ${description}=${EMPTY}
    ${passed}=    Run Keyword And Return Status    Should Not Be Empty    ${description}
    Run Keyword If    ${passed}    Log    ${description}    console=True
    Create Session    nginx    ${URL}
    ${resp}=    Get Request    nginx    ${uri}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.text}    ${body}
    [Return]    ${resp}

Start Nginx Or Reload Config
    Set Environment Variable    NGX_DIR    ${ngx_install_dir}
    ${rc}    ${output}=    Run And Return Rc And Output    sh -ex pre.sh
    Log To Console    ${output}
    Should Be Equal As Strings    ${rc}    0

Stop Nginx
    ${rc}    ${output}=        Run And Return Rc And Output    sh -ex post.sh
    Log To Console    ${output}
    Should Be Equal As Strings    ${rc}    0

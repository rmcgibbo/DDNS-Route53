{ buildPythonPackage
, fetchFromGitHub
, flit
, boto3
, beautifulsoup4
, docutils
, jmespath
, python-dateutil
, s3transfer
, six
, soupsieve
, urllib3
}:

buildPythonPackage rec {
  pname = "ddns-route53";
  version = "1.0";
  format = "pyproject";

  src = ./.;

  buildInputs = [ flit ];
  propagatedBuildInputs = [
    boto3
    beautifulsoup4
    docutils
    jmespath
    python-dateutil
    s3transfer
    six
    soupsieve
    urllib3
  ];

  postBuild = ''
    mkdir -p $out/bin
    cp ./ddns-route53 $out/bin/ddns-route53
  '';
  doCheck = false;

  meta = {
    description = "Dynamic DNS updater for AWS-Route53 (Made with Python)";
    homepage = "https://github.com/dongbum/DDNS-Route53";
  };
}

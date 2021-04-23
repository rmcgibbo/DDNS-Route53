{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.ddns-route53;
  pkg = pkgs.python3.pkgs.callPackage ./. { };
in
{
  options.services.ddns-route53 =
    {
      enable = mkEnableOption "Dynamic DNS updater";

      domain = mkOption {
        type = types.str;
        description = "Set your domain. (exclude 'http://')";
        example = "test.mydomain.com";
      };

      hosted-zone-id = mkOption {
        type = types.str;
        description = "AWS hosted zone ID for Route53";
        example = "ABCD123";
      };

      AWS_ACCESS_KEY_ID = mkOption {
        type = types.str;
        description = "AWS access key ID for Route53. WARNING: this is go be in plain-text in the nix store!";
        example = "EFGH456";
      };

      AWS_ACCESS_SECRET_KEY = mkOption {
        type = types.str;
        description = "AWS access secret key for Route53.  WARNING: this is go be in plain-text in the nix store!";
        example = "IJKL789";
      };
    };

  config = mkIf cfg.enable {
    systemd.timers.ddns-route53 = {
      wantedBy = [ "timers.target" ];
      partOf = [ "ddns-route53.service" ];
      timerConfig.OnBootSec = "1min";
      timerConfig.OnUnitActiveSec = "5min";
    };
    systemd.services.ddns-route53 = {
      wantedBy = [ "network.target" ];
      after = [ "network.target" ];
      environment = {
        DOMAIN = cfg.domain;
        AWS_HOSTED_ZONE_ID = cfg.hosted-zone-id;
        AWS_ACCESS_KEY_ID = cfg.AWS_ACCESS_KEY_ID;
        AWS_ACCESS_SECRET_KEY = cfg.AWS_ACCESS_SECRET_KEY;
        GET_IP = "AWS";
        CHECK_URL = "http://bot.whatismyipaddress.com";
        LOG = "CONSOLE";
      };
      serviceConfig = {
        type = "oneshot";
        user = "ddns-route53";
        group = "ddns-route53";
        ExecStart = "${pkg}/bin/ddns-route53";
      };
    };
  };
}

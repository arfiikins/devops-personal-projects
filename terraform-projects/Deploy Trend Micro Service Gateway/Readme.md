After deploying the main.tf, you will need to SSH SGW from bastion host and then register SGW to your V1 account.

1. Make sure you have the keypair for SSH access
2. Execute the ff commands:
    ssh -i "my-cert.pem" admin@<sgw-ip>
    enable
    configure network primary ipv4.static <interface name> <IP address in cidr format> <gateway> <dns>
        #configure network primary ipv4.static eth0 10.20.0.5/24 10.20.0.1 10.20.0.2
    connect
    register <v1-registration-token>
3. Check if Service Gateway shows Healthy status in V1 console


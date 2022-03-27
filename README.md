# AWS Suricata playground

This project provides terraform code for deploying the Suricata Intrusion Detection System into the AWS cloud and setting up mirroring sessions for all EC2 instances (except tagged ones).

## Module resouces

- EC2 instance with Suricata IDS
- Network load balancer with Suricata EC2 as a target
- Traffic mirror filters for capturing external traffic (see `mirroring.tf`)
- [Lambda function](https://github.com/vulnbe/aws-traffic-mirror-lambda) that sets up sessions for new EC2 instances
- Security groups, IAM policies and roles

## Usage

You can find an example of usage in the `examples` directory.

    export AWS_DEFAULT_PROFILE=YOUR_PROFILE
    cd examples
    terraform apply

The example creates a subnet in default VPC and deploys the project with a test EC2 instance from which you can generate traffic.
See the `examples/main.tf` for local variables.

You can connect to instances using Sessions manager:

    aws ssm start-session --target INSTANCE_ID

If you want to mirror all traffic (not only external), set the `mirror_all_traffic variable` to `true`.

Instances with any tag from the skip_tags variable aren't used for traffic mirroring.

See `variables.tf` for all available options.

## Mirroring existing environments

If you want to mirror traffic from the existing environment you should deploy this project and run the following code that gets a list of all instances in the account and runs lambda against them.

    for instance in $(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters 'Name=instance-state-name,Values=[running]' --output text); do
      aws lambda invoke --function-name TrafficMirrorLambda \
      --payload '{"source":["aws.ec2"],"detail-type":["EC2 Instance State-change Notification"],"detail":{"state":["running"],"instance-id":"'$instance'"}}' \
      --cli-binary-format raw-in-base64-out --output json outfile.txt; \
      cat outfile.txt | jq; \
    done
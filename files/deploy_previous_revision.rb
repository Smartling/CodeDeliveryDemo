#!/usr/bin/env ruby
###########################################################
###                                                     ###
### Author: Maksim Podlesnyi <mpodlesnyi@smartling.com> ###
###                                                     ###
###   Script for deploy previous revision for            ###
###  AWS Code Deploy application.                       ###
###                                                     ###
###########################################################
require 'aws-sdk-core'
require 'optparse'
require 'ostruct'

IAM_POLICIES = '''
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "codedeploy:GetDeploymentConfig",
            "Resource": "arn:aws:codedeploy:REGION:ACCOUT_ID:deploymentconfig:*"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:RegisterApplicationRevision",
            "Resource": "arn:aws:codedeploy:REGION:ACCOUT_ID:application:YOUR_APPLICATION"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:GetApplicationRevision",
            "Resource": "arn:aws:codedeploy:REGION:ACCOUT_ID:application:YOUR_APPLICATION"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:ListApplicationRevisions",
            "Resource": "arn:aws:codedeploy:REGION:ACCOUT_ID:*"
        },
        {
            "Effect": "Allow",
            "Action": "codedeploy:CreateDeployment",
            "Resource": "arn:aws:codedeploy:REGION:ACCOUT_ID:deploymentgroup:YOUR_APPLICATION/DEPLOYMENT_GROUP"
        }
    ]
}
'''

class MyOptparse

  def self.parse(args)
    options = OpenStruct.new
    options.logfile = false
    options.region = 'us-east-1'

    opt_parser = OptionParser.new do |opts|
      banner = [
        $0 + " -a my_application_name -g some_group",
      ]
      opts.banner = "Examples:\n\t" + banner.join("\n\t")

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-r", "--region REGION",
              "AWS region. Default is #{options.region}") do |region|
          options.region = region
      end

      opts.on("-a", "--application_name NAME",
              "AWS Code Deploy application name") do |name|
          options.name = name
      end

      opts.on("-g", "--deployment_group GROUP",
              "AWS Code Deploy application deployment group") do |group|
          options.group = group
      end

      opts.on_tail("-i", "--iam", "Show IAM policies") do
        puts IAM_POLICIES
        exit
      end

      opts.separator "Common options:"

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

    end
      opt_parser.parse!(args)
      if !options.name
        $stderr.print "Error: application name option has been missed\n"
        puts opt_parser
        exit(-1)
      end
      if !options.group
        $stderr.print "Error: deployment group option has been missed\n"
        puts opt_parser
        exit(-1)
      end
      options
      rescue OptionParser::ParseError
        $stderr.print "Error: " + $!.to_s + "\n"
        puts opt_parser
        exit(-1)
  end
end

def deployment_previous_revision(application_name, deployment_group, region)
  codedeploy = Aws::CodeDeploy::Client.new(region: region)
  response = codedeploy.list_application_revisions({
    application_name: application_name,
    sort_by: "lastUsedTime",
  })
  revision = response.revisions.last.to_hash

  codedeploy.create_deployment({
    application_name: application_name,
    deployment_group_name: deployment_group,
    revision: revision,
    description: "Deployment by script #{$0} from host #{Socket.gethostname}",
  })
end


if __FILE__ == $0
  options = MyOptparse.parse(ARGV)
  deployment_previous_revision(options.name, options.group, options.region)
end

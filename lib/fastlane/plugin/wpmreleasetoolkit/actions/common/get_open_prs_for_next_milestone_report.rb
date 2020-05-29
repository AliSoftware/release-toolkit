require 'fastlane/action'
require_relative '../../helper/ghhelper_helper'
require_relative '../../helper/ios/ios_version_helper'

module Fastlane
  module Actions
    class GetOpenPrsForNextMilestoneReportAction < Action
      def self.run(params)
        repository = params[:repository]

        # Get the next milestone 
        current_milestone = Fastlane::Helper::GhhelperHelper.get_current_milestone(repository)
        UI.user_error!("Can't retrieve current milestone") if current_milestone.nil?

        next_milestone = Fastlane::Helpers::IosVersionHelper.calc_next_release_version(current_milestone)
        next_milestone_info = Fastlane::Helper::GhhelperHelper.get_milestone(repository, next_milestone)

        if (((next_milestone_info.due_on.to_date - Date.today) > params[:timespan]) || (Date.today.saturday? || Date.today.sunday?))
          UI.message("Don't check today.")
          return nil
        end

        prs = Fastlane::Helper::GhhelperHelper.get_open_prs_for_milestone(repository, next_milestone)

        report = ""
        prs.each do | pr |
            report += "- #{pr.title} - #{pr.html_url} by #{pr.user.login}\n" 
        end

        return {version: next_milestone, count: prs.length, report: report}
      end

      def self.description
        "Generate the list of the open PRs which target the next milestone"
      end

      def self.authors
        ["Lorenzo Mattei"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
        "The list of the open PRs which target the next milestone"
      end

      def self.details
        # Optional:
        "Generate the list of the open PRs which target the next milestone"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repository,
                                   env_name: "GHHELPER_REPOSITORY",
                                description: "The remote path of the GH repository on which we work",
                                   optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :timespan,
                                       env_name: "GHHELPER_PRSREPORT_TIMESPAN",
                                    description: "How many days before the milestone this check should run",
                                       optional: true,
                                  default_value: 4)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end

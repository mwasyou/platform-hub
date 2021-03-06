module Agents
  class GitHubAgentService

    def initialize token:, org:, main_team_id:
      @org = org
      @main_team_id = main_team_id
      @client = Octokit::Client.new access_token: token
    end

    def onboard_user user
      with_identity(user) do |identity|
        @client.add_team_membership(@main_team_id, identity.external_username)
      end
    end

    def offboard_user user
      with_identity(user) do |identity|
        @client.remove_organization_member(@org, identity.external_username)
      end
    end

    def create_issue repo_url, title, body
      repo = Octokit::Repository.from_url repo_url
      resource = @client.create_issue repo, title, body
      resource.html_url
    end

    def repo_tree repo, sha
      @client.tree repo, sha, recursive: true
    end

    def blob_content repo, blob_sha
      @client.blob repo, blob_sha, accept: 'application/vnd.github.v3.raw'
    end

    private

    def with_identity user
      identity = user.github_identity

      if identity.blank?
        raise Errors::IdentityMissing
      end

      yield identity
    end


    module Errors
      class IdentityMissing < StandardError
      end
    end

  end
end

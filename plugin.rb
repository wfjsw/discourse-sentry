# name: discourse-sentry
# about: Discourse plugin to integrate Sentry (sentry.io)
# version: 1.1
# authors: debtcollective
# url: https://github.com/debtcollective/discourse-sentry

gem "sentry-raven"

enabled_site_setting :discourse_sentry_enabled

extend_content_security_policy(
  script_src: ['https://browser.sentry-cdn.com/5.10.2/bundle.min.js']
)

PLUGIN_NAME ||= "DiscourseSentry".freeze

after_initialize do
  if SiteSetting.discourse_sentry_enabled && SiteSetting.discourse_sentry_dsn.present?
    Raven.configure do |config|
      config.dsn = SiteSetting.discourse_sentry_dsn
      config.release = (Discourse.git_version == 'unknown' ? nil : Discourse.git_version)
    end

    class ::ApplicationController
      before_action :set_raven_context

      private

      def set_raven_context
        Raven.user_context(id: current_user.id, username: current_user.username) if current_user
        Raven.extra_context(params: params.to_unsafe_h, url: request.url)
      end
    end
  end
end

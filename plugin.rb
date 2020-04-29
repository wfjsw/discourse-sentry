# name: discourse-sentry
# about: Discourse plugin to integrate Sentry (sentry.io)
# version: 1.2
# authors: debtcollective
# url: https://github.com/debtcollective/discourse-sentry

gem "sentry-raven", "3.0.0"

enabled_site_setting :discourse_sentry_enabled

extend_content_security_policy(
  script_src: ['https://cdn.jsdelivr.net/npm/@sentry/browser@5.15.4/build/bundle.min.js'],
)

register_html_builder('server:before-head-close') do
  '<script src="https://cdn.jsdelivr.net/npm/@sentry/browser@5.15.4/build/bundle.min.js" integrity="sha256-86s3lk2js5wJqBQvyGApEXNTL2smDMvMYLRmswvdHYI=" crossorigin="anonymous"></script>'
end

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

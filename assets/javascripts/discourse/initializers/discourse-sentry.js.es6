import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "discourse-sentry",

  initialize() {
    withPluginApi("0.8.36", (api) => {
      const src = "https://browser.sentry-cdn.com/5.10.2/bundle.min.js";
      const enabled = Discourse.SiteSettings.discourse_sentry_enabled;
      const dsn = Discourse.SiteSettings.discourse_sentry_dsn;

      if (!enabled || !dsn) {
        return;
      }

      const script = document.createElement("script");

      script.onload = () => {
        window.Sentry.init({
          dsn
        });

        const currentUser = api.getCurrentUser();

        if (currentUser) {
          const { id, username } = currentUser;

          window.Sentry.configureScope(scope => {
            scope.setUser({ id, username });
          });
        }
      };

      script.src = src;
      document.head.appendChild(script);
    });
  }
};

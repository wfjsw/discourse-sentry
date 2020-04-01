import { withPluginApi } from "discourse/lib/plugin-api";

export default {
    name: "discourse-sentry",

    initialize() {
        withPluginApi("0.8.36", (api) => {
            const enabled = Discourse.SiteSettings.discourse_sentry_enabled;
            const dsn = Discourse.SiteSettings.discourse_sentry_dsn;

            if (enabled || dsn) {
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
            }
        });
    }
};

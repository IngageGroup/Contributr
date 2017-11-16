exports.config = {
    // See http://brunch.io/#documentation for docs.
    files: {
        javascripts: {
            joinTo: "js/app.js"
        },
        stylesheets: {
            joinTo: "css/app.css",
            order: {
                after: ["web/static/css/app.css"] // concat app.css last
            }
        },
        templates: {
            joinTo: "js/app.js"
        }
    },

    conventions: {
        // This option sets where we should place non-css and non-js assets in.
        // By default, we set this to "/web/static/assets". Files in this directory
        // will be copied to `paths.public`, which is "priv/static" by default.
        assets: /^(web\/static\/assets)/
    },

    // Phoenix paths configuration
    paths: {
        // Dependencies and current project directories to watch
        watched: [
            "web/static",
            "test/static"
        ],

        // Where to compile files to
        public: "priv/static"
    },

    // Configure your plugins
    plugins: {
        babel: {
            // Do not use ES6 compiler in vendor code
            ignore: [/(web\/static\/vendor)|node_modules/]
        },
        sass: {
            options: {
                includePaths: [
                    "node_modules/font-awesome/scss",
                    "node_modules/roboto-fontface/css/roboto/sass",
                    "node_modules/muicss/lib/sass"], // tell sass-brunch where to look for files to @import
            },
            precision: 8 // minimum precision required by bootstrap-sass
        },
        copycat: {
            "fonts": [
                "node_modules/font-awesome/scss/",
                "node_modules/roboto-fontface/css/roboto/sass/"]
        }
    },

    modules: {
        autoRequire: {
            "js/app.js": ["web/static/js/app"]
        }
    },

    npm: {
        enabled: true,
        globals: {
            $: 'jquery',
            jQuery: 'jquery',
            jsPDF: 'jspdf'
        },
        styles: {
        }
    }

};

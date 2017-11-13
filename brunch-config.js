exports.config = {
    // See http://brunch.io/#documentation for docs.
    files: {
        javascripts: {
            joinTo: "js/app.js"
        },
        stylesheets: {
            joinTo: {
                "css/app.css": /^(web\/static\/cs|node_modules|^nodemodules\/muicss-webcomp\/packages\/cdn\/css)/
            }
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
            ignore: [/web\/static\/vendor/]
        },
        copycat: {
            "fonts": ["node_modules/material-design-icons/iconfont",
                "node_modules/font-awesome/fonts",
                "node_modules/roboto-fontface/fonts"]
        },
        postcss: {
            processors: [
                require('autoprefixer')(['last 8 versions']),
                require('csswring')({
                    map: true,
                    preserveHacks: true
                })
            ]
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
            'phoenix_html': 'phoenix_html',
            muicss:'muicss-webcomp'
        }
    }

};

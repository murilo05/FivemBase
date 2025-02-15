Vue.component('message', {
    template: '#message_template',
    data() {
        return {};
    },
    computed: {
        textEscaped() {
            let s = this.template ? this.template : this.templates[this.templateId];

            if (this.template) {
                //We disable templateId since we are using a direct raw template
                this.templateId = -1;
            }

            //This hack is required to preserve backwards compatability
            if (this.templateId == CONFIG.defaultTemplateId &&
                this.args.length == 1) {
                s = this.templates[CONFIG.defaultAltTemplateId] //Swap out default template :/
            }

            s = s.replace(/{(\d+)}/g, (match, number) => {
                const argEscaped = this.args[number] != undefined ? this.escape(this.args[number]) : match
                if (number == 0 && this.color) {
                    //color is deprecated, use templates or ^1 etc.
                    return this.colorizeOld(argEscaped);
                }
                return argEscaped;
            });
            return this.colorize(s);
        },
    },
    methods: {
        colorizeOld(str) {
            return `<div style="color: rgb(${this.color[0]}, ${this.color[1]}, ${this.color[2]})">${str}</div>`
        },
        colorize(str) {
            let s = "<div>" + (str.replace(/\^([0-9])/g, (str, color) => `</div><div class="color-${color}">`)) + "</div>";
            const styleDict = {
                '_': 'text-decoration: underline;',
                '~': 'text-decoration: line-through;',
                '=': 'text-decoration: underline line-through;',
                'r': 'text-decoration: none;font-weight: normal;',
            };

            const styleRegex = /\^(\_|\*|\=|\~|\/|r)(.*?)(?=$|\^r|<\/em>)/;
            while (s.match(styleRegex)) { //Any better solution would be appreciated :P
                s = s.replace(styleRegex, (str, style, inner) => `<em style="${styleDict[style]}">${inner}</em>`)
            }
            return s.replace(/<div[^>]*><\/div[^>]*>/g, '');
        },
        escape(unsafe) {
            return String(unsafe)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
        },
    },
    props: {
        templates: {
            type: Object,
        },
        args: {
            type: Array,
        },
        template: {
            type: String,
            default: null,
        },
        templateId: {
            type: String,
            default: CONFIG.defaultTemplateId,
        },
        multiline: {
            type: Boolean,
            default: false,
        },
        color: { //deprecated
            type: Array,
            default: false,
        },
    },
});
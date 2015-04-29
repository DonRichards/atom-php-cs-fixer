{CompositeDisposable} = require 'atom'
{BufferedProcess} = require 'atom'

module.exports = PhpCsFixer =
  subscriptions: null
  config:
    executablePath:
      type: 'string'
      default: 'php php-cs-fixer.phar'
      description: 'the path to the `php-cs-fixer` executable'
    level:
      type: 'string'
      enum: ['psr0', 'psr1', 'psr2', 'symfony']
      default: 'psr2'
      description: 'for example: psr0, psr1, psr2 or symfony'
    fixers:
      type: 'string'
      default: ''
      description: 'a list of fixers, for example: `linefeed,short_tag,indentation`. See <http://cs.sensiolabs.org/#usage> for a complete list'


  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'php-cs-fixer:fix': => @fix()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  fix: ->
    atom.config.observe 'php-cs-fixer.executablePath', =>
      @executablePath = atom.config.get 'php-cs-fixer.executablePath'

    atom.config.observe 'php-cs-fixer.level', =>
      @level = atom.config.get 'php-cs-fixer.level'

    atom.config.observe 'php-cs-fixer.fixers', =>
      @fixers = atom.config.get 'php-cs-fixer.fixers'

    editor = atom.workspace.getActivePaneItem()

    filePath = editor.getPath() if editor && editor.getPath

    command = @executablePath

    # init opptions
    args = ['fix', filePath]

    # add optional opptions
    args.push '--level=' + @level if @level
    args.push '--fixers=' + @fixers if @fixers

    stdout = (output) -> console.log(output)
    stderr = (output) -> console.error(output)
    exit = (code) -> console.log("#{command} exited with code: #{code}")

    process = new BufferedProcess({command: command, args: args, stdout: stdout, stderr: stderr, exit: exit}) if filePath

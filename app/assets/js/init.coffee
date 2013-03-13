$ =>
    # Connect to websocket
    socket = io.connect 'http://localhost'

    # Datatable settings
    tableSettings =
        sDom: "<'row'<'span6'><'span6'f>r>t<'row'<'span6'><'span6'p>>"
        bPaginate: false
        bScrollAutoCSS: false
        bScrollCollapse: true
        aoColumns: [
            {
                mData: 'message'
            }
            , {
                mData: 'timestamp'
            }
        ]
        oLanguage:
          sLengthMenu: "_MENU_ records per page"

    # Create a new Logger instance
    logger = new Logger
        el: '#demo'
        messageLimit: 1500
        updateLimit: 1000
        tableSettings: tableSettings

    $('.start').click ->
        # Send start sig to server
        socket.emit 'start'

    $('.stop').click ->
        socket.emit 'stop'

    $('.clear').click ->
        logger.clear()

    # Listen for incoming batch msgs
    socket.on 'batch', (data) ->
        logger.addData data.batch, false
        logger.oTable.fnDraw(false)

class @Logger
    constructor: (options) ->
        @MAX_MESSAGES = options.messageLimit || 10000
        @MAX_UPDATE = options.updateLimit || 1000
        @originalTitle = document.title

        @oTable = $(options.el).dataTable(options.tableSettings)
        @setTitle()

    getData: ->
        return @oTable.fnGetData()

    addData: (data, redraw = false) ->
        if @getData().length < @MAX_MESSAGES
            @oTable.fnAddData data, redraw

        @setTitle()

    # Clear all rows & data from table
    clear: ->
        @oTable.fnClearTable()
        @setTitle()

    setTitle: ->
        document.title = "#{@originalTitle} (#{@oTable.fnGetData().length || 0})"
class ZCL_REST_HTTP_CLIENT definition
  public
  final
  create public .

public section.

  interfaces IF_REST_RESOURCE .
  interfaces IF_REST_CLIENT .

  methods CONSTRUCTOR
    importing
      !IO_HTTP_CLIENT type ref to IF_HTTP_CLIENT .
  methods REFRESH_REQUEST .

  methods PATCH
    importing
        !IO_ENTITY type ref to IF_REST_ENTITY.
  PROTECTED SECTION.
private section.

  data MO_HTTP_CLIENT type ref to IF_HTTP_CLIENT .
  data MO_REQUEST_ENTITY type ref to IF_REST_ENTITY .

  methods SEND_RECEIVE
    importing
      !IV_HTTP_METHOD type STRING
      !IO_ENTITY type ref to IF_REST_ENTITY optional .
ENDCLASS.



CLASS ZCL_REST_HTTP_CLIENT IMPLEMENTATION.


  METHOD CONSTRUCTOR.
    super->constructor( ).

    mo_http_client = io_http_client.
    IF mo_http_client IS INITIAL.
      RAISE EXCEPTION TYPE cx_rest_client_exception
        EXPORTING
          textid = cx_rest_client_exception=>http_client_initial.
    ENDIF.
  ENDMETHOD.                    "constructor


METHOD IF_REST_CLIENT~CLOSE.
  IF mo_http_client IS BOUND.
    mo_http_client->close( ).
    CLEAR mo_http_client.
  ENDIF.
ENDMETHOD.


METHOD IF_REST_CLIENT~CREATE_REQUEST_ENTITY.
  ro_entity = mo_request_entity = cl_rest_message_builder=>create_http_message_entity( mo_http_client->request ).
ENDMETHOD.


METHOD IF_REST_CLIENT~GET_RESPONSE_ENTITY.
  ro_response_entity = cl_rest_message_builder=>create_http_message_entity( mo_http_client->response ).
ENDMETHOD.


method IF_REST_CLIENT~GET_RESPONSE_HEADER.
  rv_value = mo_http_client->response->get_header_field( iv_name ).
endmethod.


METHOD IF_REST_CLIENT~GET_RESPONSE_HEADERS.
  mo_http_client->response->get_header_fields( CHANGING fields = rt_header_fields ).
ENDMETHOD.


METHOD IF_REST_CLIENT~GET_STATUS.
  mo_http_client->response->get_status( IMPORTING code = rv_status ).
ENDMETHOD.


METHOD IF_REST_CLIENT~SET_REQUEST_HEADER.
  mo_http_client->request->set_header_field( name = iv_name value = iv_value ).
ENDMETHOD.


method IF_REST_CLIENT~SET_REQUEST_HEADERS.
  mo_http_client->request->set_header_fields( it_header_fields ).
endmethod.


METHOD IF_REST_RESOURCE~DELETE.
  send_receive( if_rest_message=>gc_method_delete ).
ENDMETHOD.


  METHOD IF_REST_RESOURCE~GET.
    send_receive( if_rest_message=>gc_method_get ).
  ENDMETHOD.                    "IF_REST_RESOURCE~GET


METHOD IF_REST_RESOURCE~HEAD.
  send_receive( if_rest_message=>gc_method_head ).
ENDMETHOD.


method IF_REST_RESOURCE~OPTIONS.
  send_receive( if_rest_message=>gc_method_options ).
endmethod.


method IF_REST_RESOURCE~POST.
  send_receive( iv_http_method = if_rest_message=>gc_method_post io_entity = io_entity ).
endmethod.


method IF_REST_RESOURCE~PUT.
  send_receive( iv_http_method = if_rest_message=>gc_method_put io_entity = io_entity ).
endmethod.


method PATCH.
  send_receive( iv_http_method = if_rest_message=>gc_method_put io_entity = io_entity ).
endmethod.

  METHOD REFRESH_REQUEST.
    mo_http_client->refresh_request( ).
    CLEAR mo_request_entity.
  ENDMETHOD.


  METHOD SEND_RECEIVE.

    "add first entity to the process table
    mo_http_client->request->set_method( iv_http_method ).

    " todo: this is not very nice
    " problem: the user of the rest client MUST currently pass the
    " same entity which was created via create_request_entity
    " idea for improvement: instead of raising exception; set the passed entity
    " into the http request (overriden previous settings)
    IF io_entity IS NOT INITIAL.
      IF io_entity <> mo_request_entity.
        RAISE EXCEPTION TYPE cx_rest_client_exception
          EXPORTING
            textid = cx_rest_client_exception=>http_client_invalid_entity.
      ENDIF.
    ENDIF.

    CALL METHOD mo_http_client->send
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        http_invalid_timeout       = 4
        OTHERS                     = 5.

    IF sy-subrc = 0.
      CALL METHOD mo_http_client->receive
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3
          OTHERS                     = 5.
    ENDIF.

    " error handlign after send and receive
    IF sy-subrc <> 0.

      CASE sy-subrc.
        WHEN 1.
          RAISE EXCEPTION TYPE cx_rest_client_exception
            EXPORTING
              textid = cx_rest_client_exception=>http_client_comm_failure.
        WHEN 2.
          RAISE EXCEPTION TYPE cx_rest_client_exception
            EXPORTING
              textid = cx_rest_client_exception=>http_client_invalid_state.
        WHEN 3.
          RAISE EXCEPTION TYPE cx_rest_client_exception
            EXPORTING
              textid = cx_rest_client_exception=>http_client_processing_failed.
        WHEN 4.
          RAISE EXCEPTION TYPE cx_rest_client_exception
            EXPORTING
              textid = cx_rest_client_exception=>http_client_invalid_timeout.
        WHEN 5.
          RAISE EXCEPTION TYPE cx_rest_client_exception.
      ENDCASE.

    ENDIF.

  ENDMETHOD.                    "SEND_REEIVE
ENDCLASS.

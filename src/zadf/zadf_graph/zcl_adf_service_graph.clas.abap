CLASS zcl_adf_service_graph DEFINITION

  PUBLIC

  INHERITING FROM zcl_adf_service

  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_adf_service_graph.

  PROTECTED SECTION.

  PRIVATE SECTION.

    METHODS send_request
      IMPORTING
          VALUE(iv_aad_token) TYPE string
          VALUE(iv_path_suffix) TYPE string
          VALUE(iv_content_type) TYPE string OPTIONAL
          VALUE(iv_request_string_body) TYPE string OPTIONAL
          VALUE(iv_request_binary_body) TYPE xstring OPTIONAL
      EXPORTING
          VALUE(ev_http_status) TYPE i
      RETURNING
          VALUE(rt_response_data) TYPE string
      RAISING
          zcx_adf_service .

ENDCLASS.



CLASS ZCL_ADF_SERVICE_GRAPH IMPLEMENTATION.


  METHOD zif_adf_service_graph~create_folder.
    TYPES: BEGIN OF response,
            value TYPE zif_adf_service_graph~item,
           END OF response.
    DATA: ls_response_data TYPE string,
          ls_path_suffix TYPE string,
          ls_response TYPE response,
          lv_folder_request_json TYPE string.


    IF go_rest_api is BOUND.

      IF iv_parent_id IS INITIAL.
        ls_path_suffix = |/users/| && iv_user_id && |/drive/root/children|.
      ELSE.
        ls_path_suffix = |/users/| && iv_user_id && |/drive/items/| && iv_parent_id && |/children|.
      ENDIF.
      lv_folder_request_json = `{"name": "&1","folder": {},"@microsoft.graph.conflictBehavior": "&2"}`.
      REPLACE FIRST OCCURRENCE OF '&1' IN lv_folder_request_json WITH iv_folder_name.
      REPLACE FIRST OCCURRENCE OF '&2' IN lv_folder_request_json WITH iv_conflict_behavior.

      ls_response_data = send_request(
        EXPORTING
          iv_aad_token = iv_aad_token
          iv_path_suffix = ls_path_suffix
          iv_content_type = 'application/json; charset=utf-8'
          iv_request_string_body = lv_folder_request_json
        IMPORTING
          ev_http_status = ev_http_status
      ).

      /ui2/cl_json=>deserialize(
                          EXPORTING
                            json = ls_response_data   " Data to serialize
                          "  pretty_name = abap_true    " Pretty Print property names
                          CHANGING
                            data = ls_response
                        ).
      rt_folder = ls_response-value.
    ENDIF.
  ENDMETHOD.


  METHOD zif_adf_service_graph~get_files.

    TYPES: BEGIN OF response,
            value TYPE zif_adf_service_graph~items,
           END OF response.
    DATA: ls_response_data TYPE string,
          ls_path_suffix TYPE string,
          ls_response TYPE response.

    IF go_rest_api is BOUND.

      ls_path_suffix = |/users/| && iv_user_id && |/drive/root/children|.

      ls_response_data = send_request(
        EXPORTING
          iv_aad_token = iv_aad_token
          iv_path_suffix = ls_path_suffix
          iv_content_type = 'application/json; charset=utf-8'
        IMPORTING
          ev_http_status = ev_http_status
      ).

      /ui2/cl_json=>deserialize(
                          EXPORTING
                            json = ls_response_data   " Data to serialize
                          "  pretty_name = abap_true    " Pretty Print property names
                          CHANGING
                            data = ls_response
                        ).
      rt_files = ls_response-value.
    ENDIF.
  ENDMETHOD.


  METHOD zif_adf_service_graph~search_file.
    TYPES: BEGIN OF response,
            value TYPE zif_adf_service_graph~items,
           END OF response.
    DATA: ls_response_data TYPE string,
          ls_path_suffix TYPE string,
          ls_response TYPE response.

    IF go_rest_api is BOUND.

      ls_path_suffix = |/users/| && iv_user_id && |/drive/root/search(q='| && iv_search_pattern && |')|.

      ls_response_data = send_request(
        EXPORTING
          iv_aad_token = iv_aad_token
          iv_path_suffix = ls_path_suffix
          iv_content_type = 'application/json; charset=utf-8'
        IMPORTING
          ev_http_status = ev_http_status
      ).

      /ui2/cl_json=>deserialize(
                          EXPORTING
                            json = ls_response_data   " Data to serialize
                          "  pretty_name = abap_true    " Pretty Print property names
                          CHANGING
                            data = ls_response
                        ).
      rt_files = ls_response-value.
    ENDIF.
  ENDMETHOD.


  METHOD zif_adf_service_graph~delete_file.
    DATA: ls_path_suffix TYPE string.

    IF go_rest_api is BOUND.

      ls_path_suffix = |/users/| && iv_user_id && |/drive/items/| && iv_file_id.

      send_request(
        EXPORTING
          iv_aad_token = iv_aad_token
          iv_path_suffix = ls_path_suffix
        IMPORTING
          ev_http_status = ev_http_status
      ).
    ENDIF.
  ENDMETHOD.


   METHOD zif_adf_service_graph~update_file.
    TYPES: BEGIN OF response,
            value TYPE zif_adf_service_graph~item,
           END OF response.
    DATA: ls_response_data TYPE string,
          ls_path_suffix TYPE string,
          ls_response TYPE response,
          lv_update_file_request_json TYPE string.
    IF go_rest_api is BOUND.

      ls_path_suffix = |/users/| && iv_user_id && |/drive/items/| && iv_file_id.
      lv_update_file_request_json = `{"name": "&1"}`.
      REPLACE FIRST OCCURRENCE OF '&1' IN lv_update_file_request_json WITH iv_new_name .

      ls_response_data = send_request(
        EXPORTING
          iv_aad_token = iv_aad_token
          iv_path_suffix = ls_path_suffix
          iv_content_type = 'application/json; charset=utf-8'
          iv_request_string_body = lv_update_file_request_json
        IMPORTING
          ev_http_status = ev_http_status
      ).

      /ui2/cl_json=>deserialize(
                          EXPORTING
                            json = ls_response_data   " Data to serialize
                          "  pretty_name = abap_true    " Pretty Print property names
                          CHANGING
                            data = ls_response
                        ).
      rt_file = ls_response-value.
    ENDIF.
  ENDMETHOD.


  METHOD zif_adf_service_graph~upload_file_by_path.
    TYPES: BEGIN OF response,
            value TYPE zif_adf_service_graph~item,
           END OF response.
    DATA: ls_content_type TYPE string,
          ls_response_data TYPE string,
          ls_path_suffix TYPE string,
          ls_response TYPE response.
    IF go_rest_api is BOUND.

      ls_path_suffix = |/users/| && iv_user_id && |/drive/root:| && iv_path && |:/content|.
      IF iv_content_type IS INITIAL.
        ls_content_type = 'application/x-binary'.
      ELSE.
        ls_content_type = iv_content_type.
      ENDIF.

      ls_response_data = send_request(
        EXPORTING
          iv_aad_token = iv_aad_token
          iv_path_suffix = ls_path_suffix
          iv_content_type = ls_content_type
          iv_request_binary_body = iv_content
        IMPORTING
          ev_http_status = ev_http_status
      ).

      /ui2/cl_json=>deserialize(
                          EXPORTING
                            json = ls_response_data   " Data to serialize
                          "  pretty_name = abap_true    " Pretty Print property names
                          CHANGING
                            data = ls_response
                        ).
      rt_file = ls_response-value.
    ENDIF.
  ENDMETHOD.

  METHOD zif_adf_service_graph~upload_file_by_id.
    TYPES: BEGIN OF response,
            value TYPE zif_adf_service_graph~item,
           END OF response.
    DATA: ls_content_type TYPE string,
          ls_response_data TYPE string,
          ls_path_suffix TYPE string,
          ls_response TYPE response.
    IF go_rest_api is BOUND.

      ls_path_suffix = |/users/| && iv_user_id && |/drive/items/| && iv_file_id && |/content|.
      IF iv_content_type IS INITIAL.
        ls_content_type = 'application/x-binary'.
      ELSE.
        ls_content_type = iv_content_type.
      ENDIF.

      ls_response_data = send_request(
        EXPORTING
          iv_aad_token = iv_aad_token
          iv_path_suffix = ls_path_suffix
          iv_content_type = ls_content_type
          iv_request_binary_body = iv_content
        IMPORTING
          ev_http_status = ev_http_status
      ).

      /ui2/cl_json=>deserialize(
                          EXPORTING
                            json = ls_response_data   " Data to serialize
                          "  pretty_name = abap_true    " Pretty Print property names
                          CHANGING
                            data = ls_response
                        ).
      rt_file = ls_response-value.
    ENDIF.
  ENDMETHOD.


  METHOD zif_adf_service_graph~get_file_by_path.
    DATA: ls_response_data TYPE string,
          ls_path_suffix TYPE string.

    IF go_rest_api is BOUND.

      IF iv_file_path IS INITIAL OR iv_file_path EQ '/'.
        ls_path_suffix = |/users/| && iv_user_id && |/drive/root|.
      ELSE.
        ls_path_suffix = |/users/| && iv_user_id && |/drive/root:| && iv_file_path.
      ENDIF.

      ls_response_data = send_request(
        EXPORTING
          iv_aad_token = iv_aad_token
          iv_path_suffix = ls_path_suffix
        IMPORTING
          ev_http_status = ev_http_status
      ).

      /ui2/cl_json=>deserialize(
                          EXPORTING
                            json = ls_response_data   " Data to serialize
                          "  pretty_name = abap_true    " Pretty Print property names
                          CHANGING
                            data = rt_file
                        ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_adf_service_graph~get_file_download_url.

    DATA: lo_response TYPE REF TO if_rest_entity,
          lo_request TYPE REF TO if_rest_entity,
          lv_path_prefix TYPE string,
          lv_host_s TYPE string.

    IF go_rest_api is BOUND.

        lv_path_prefix = |/users/| && iv_user_id && |/drive/root/items/| && iv_file_id && |/content|.
      IF NOT lv_path_prefix IS INITIAL.
        go_rest_api->zif_rest_framework~set_uri( lv_path_prefix ).
      ENDIF.
      lv_host_s = gv_host.
      add_request_header( iv_name = 'Host' iv_value = lv_host_s ).
      add_request_header( iv_name = 'Authorization' iv_value = |Bearer | && iv_aad_token ).

      lo_response = go_rest_api->zif_rest_framework~execute(
        io_entity = lo_request
        async     = gv_asynchronous
        is_retry  = gv_is_try
      ).

      ev_http_status = go_rest_api->get_status( ).

      IF lo_response IS BOUND.
        DATA(response) = lo_response->get_string_data( ).
        IF ev_http_status = 400.
          RAISE EXCEPTION TYPE zcx_adf_service
            EXPORTING
              textid         = zcx_adf_service_graph=>general_exception
              text           = response
              interface_id   = gv_interface_id.
        ELSE.
          rt_download_url = lo_response->get_header_field( iv_name = 'Content-Location' ).
        ENDIF.
      ELSE.

        RAISE EXCEPTION TYPE zcx_adf_service
          EXPORTING
            textid       = zcx_adf_service=>restapi_response_not_found
            interface_id = gv_interface_id.
      ENDIF.
      go_rest_api->close( ).
    ENDIF.
  ENDMETHOD.


  METHOD send_request.
    DATA: lo_response TYPE REF TO if_rest_entity.

    go_rest_api->zif_rest_framework~set_uri( CL_HTTP_UTILITY=>IF_HTTP_UTILITY~ESCAPE_URL( iv_path_suffix ) ).

    IF iv_content_type IS NOT INITIAL.
      add_request_header( iv_name = 'Content-Type' iv_value = iv_content_type ).
    ENDIF.
    add_request_header( iv_name = 'Host' iv_value = gv_host ).
    add_request_header( iv_name = 'Authorization' iv_value = |Bearer | && iv_aad_token ).
    IF iv_request_string_body IS NOT INITIAL.
      go_rest_api->set_string_body( body = iv_request_string_body ).
    ENDIF.
    IF iv_request_binary_body IS NOT INITIAL.
      go_rest_api->set_binary_body( body = iv_request_binary_body ).
    ENDIF.

    lo_response = go_rest_api->zif_rest_framework~execute(
      async     = gv_asynchronous
      is_retry  = gv_is_try
    ).
    ev_http_status = go_rest_api->get_status(  ).


    IF lo_response IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_adf_service
        EXPORTING
          textid       = zcx_adf_service=>restapi_response_not_found
          interface_id = gv_interface_id.
    ELSE.
      DATA(response) = lo_response->get_string_data(  ).
      IF ev_http_status = 400.
        RAISE EXCEPTION TYPE zcx_adf_service
          EXPORTING
            textid         = zcx_adf_service_graph=>general_exception
            text           = response
            interface_id   = gv_interface_id.
      ENDIF.
      rt_response_data = response.
    ENDIF.
    go_rest_api->close( ).
  ENDMETHOD.
ENDCLASS.


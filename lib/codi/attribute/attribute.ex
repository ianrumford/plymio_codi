defmodule Plymio.Codi.Attribute do
  @moduledoc false

  defmacro __using__(_opts \\ []) do
    quote do
      @plymio_codi_key_transform :transform
      @plymio_codi_key_postwalk :postwalk

      @plymio_codi_key_proxy :proxy
      @plymio_codi_key_form :form
      @plymio_codi_key_forms :forms
      @plymio_codi_key_vekil :vekil
      @plymio_codi_key_pattern :pattern
      @plymio_codi_key_stage :stage
      @plymio_codi_key_name :name
      @plymio_codi_key_typespec_spec :typespec_spec
      @plymio_codi_key_doc :doc
      @plymio_codi_key_since :since
      @plymio_codi_key_prefix :prefix
      @plymio_codi_key_args :args
      @plymio_codi_key_sig :sig
      @plymio_codi_key_result :result
      @plymio_codi_key_bang :bang
      @plymio_codi_key_bang_module :bang_module
      @plymio_codi_key_delegate :delegate

      @plymio_codi_key_take :take
      @plymio_codi_key_drop :drop
      @plymio_codi_key_filter :filter
      @plymio_codi_key_reject :reject
      @plymio_codi_key_to :to
      @plymio_codi_key_as :as
      @plymio_codi_key_arity :arity

      @plymio_codi_key_get_docs :get_docs

      @plymio_codi_key_proxy_name :proxy_name
      @plymio_codi_key_vekil :vekil

      @plymio_codi_key_fun_module :fun_module
      @plymio_codi_key_fun_name :fun_name
      @plymio_codi_key_fun_args :fun_args
      @plymio_codi_key_fun_sig :fun_sig
      @plymio_codi_key_fun_arity :fun_arity
      @plymio_codi_key_fun_doc :fun_doc
      @plymio_codi_key_fun_default :fun_default
      @plymio_codi_key_fun_namer :fun_namer
      @plymio_codi_key_fun_key :fun_key
      @plymio_codi_key_fun_verb :fun_verb
      @plymio_codi_key_fun_spec :fun_spec

      @plymio_codi_key_bang_module :bang_module
      @plymio_codi_key_bang_name :bang_name
      @plymio_codi_key_bang_doc :bang_doc
      @plymio_codi_key_bang_args :bang_args
      @plymio_codi_key_bang_arity :bang_arity

      @plymio_codi_key_delegate_module :delegate_module
      @plymio_codi_key_delegate_name :delegate_name
      @plymio_codi_key_delegate_args :delegate_args
      @plymio_codi_key_delegate_arity :delegate_arity
      @plymio_codi_key_delegate_doc :delegate_doc

      @plymio_codi_key_option_getset :option_getset
      @plymio_codi_key_struct_getset :struct_getset

      @plymio_codi_key_typespec_spec_name :typespec_spec_name
      @plymio_codi_key_typespec_spec_args :typespec_spec_args
      @plymio_codi_key_typespec_spec_arity :typespec_spec_arity
      @plymio_codi_key_typespec_spec_result :typespec_spec_result

      @plymio_codi_key_status :status

      @plymio_codi_key_default :default
      @plymio_codi_key_key :key
      @plymio_codi_key_validate_fun :validate_fun

      @plymio_codi_field_snippets :snippets
      @plymio_codi_field_stage_dispatch :stage_dispatch
      @plymio_codi_field_patterns :patterns
      @plymio_codi_field_pattern_express_dispatch :pattern_express_dispatch
      @plymio_codi_field_pattern_dicts :pattern_dicts
      @plymio_codi_field_pattern_normalisers :pattern_normalisers
      @plymio_codi_field_forms @plymio_codi_key_forms
      @plymio_codi_field_vekil @plymio_codi_key_vekil
      @plymio_codi_field_module_fva_dict :module_fva_dict
      @plymio_codi_field_module_doc_dict :module_doc_dict

      @plymio_codi_pattern_form @plymio_codi_key_form
      @plymio_codi_pattern_proxy @plymio_codi_key_proxy
      @plymio_codi_pattern_doc @plymio_codi_key_doc
      @plymio_codi_pattern_since @plymio_codi_key_since
      @plymio_codi_pattern_bang @plymio_codi_key_bang
      @plymio_codi_pattern_bang_module @plymio_codi_key_bang_module
      @plymio_codi_pattern_typespec_spec @plymio_codi_key_typespec_spec
      @plymio_codi_pattern_delegate @plymio_codi_key_delegate
      @plymio_codi_pattern_delegate_module @plymio_codi_key_delegate_module

      @plymio_codi_pattern_types [
        @plymio_codi_pattern_form,
        @plymio_codi_pattern_doc,
        @plymio_codi_pattern_since,
        @plymio_codi_pattern_bang,
        @plymio_codi_pattern_bang_module,
        @plymio_codi_pattern_typespec_spec,
        @plymio_codi_pattern_delegate,
        @plymio_codi_pattern_delegate_module,
        @plymio_codi_pattern_proxy
      ]

      @plymio_codi_field_alias_snippets {@plymio_codi_field_snippets, nil}
      @plymio_codi_field_alias_stage_dispatch {@plymio_codi_field_stage_dispatch, nil}
      @plymio_codi_field_alias_patterns {@plymio_codi_field_patterns, nil}
      @plymio_codi_field_alias_pattern_dicts {@plymio_codi_field_pattern_dicts, nil}
      @plymio_codi_field_alias_pattern_normalisers {@plymio_codi_field_pattern_normalisers, nil}
      @plymio_codi_field_alias_pattern_express_dispatch {@plymio_codi_field_pattern_express_dispatch,
                                                         nil}
      @plymio_codi_field_alias_forms {@plymio_codi_field_forms, nil}
      @plymio_codi_field_alias_vekil {@plymio_codi_field_vekil, [:vekil]}
      @plymio_codi_field_alias_module_fva_dict {@plymio_codi_field_module_fva_dict, []}
      @plymio_codi_field_alias_module_doc_dict {@plymio_codi_field_module_doc_dict, []}

      @plymio_codi_key_alias_pattern {@plymio_codi_key_pattern, nil}
      @plymio_codi_key_alias_status {@plymio_codi_key_status, nil}
      @plymio_codi_key_alias_form {@plymio_codi_key_form, nil}

      @plymio_codi_pattern_alias_doc {@plymio_codi_pattern_doc, nil}
      @plymio_codi_pattern_alias_bang {@plymio_codi_pattern_bang, nil}
      @plymio_codi_pattern_alias_bang_module {@plymio_codi_pattern_bang_module, nil}
      @plymio_codi_pattern_alias_delegate {@plymio_codi_pattern_delegate, nil}
      @plymio_codi_pattern_alias_delegate_module {@plymio_codi_pattern_delegate_module, nil}
      @plymio_codi_pattern_alias_typespec_spec {@plymio_codi_pattern_typespec_spec, [:spec]}
      @plymio_codi_pattern_alias_doc {@plymio_codi_pattern_doc, nil}
      @plymio_codi_pattern_alias_since {@plymio_codi_pattern_since, nil}
      @plymio_codi_pattern_alias_proxy {@plymio_codi_pattern_proxy, [:proxies]}
      @plymio_codi_pattern_alias_form {@plymio_codi_pattern_form, [:forms, :ast, :asts]}

      @plymio_codi_key_alias_since {@plymio_codi_key_since, nil}

      @plymio_codi_key_alias_fun_module {@plymio_codi_key_fun_module,
                                         [:module, :fun_mod, :function_module]}
      @plymio_codi_key_alias_fun_name {@plymio_codi_key_fun_name, [:name, :function_name]}
      @plymio_codi_key_alias_fun_args {@plymio_codi_key_fun_args, [:args, :function_args]}
      @plymio_codi_key_alias_fun_sig {@plymio_codi_key_fun_sig,
                                      [:sig, :function_sig, :fun_signature, :function_signature]}
      @plymio_codi_key_alias_fun_arity {@plymio_codi_key_fun_arity, [:arity, :function_arity]}
      @plymio_codi_key_alias_fun_doc {@plymio_codi_key_fun_doc, [:doc, :function_doc]}
      @plymio_codi_key_alias_fun_key {@plymio_codi_key_fun_key,
                                      [:key, :field, :function_key, :function_field, :fun_field]}
      @plymio_codi_key_alias_fun_verb {@plymio_codi_key_fun_verb, [:verb, :function_verb]}
      @plymio_codi_key_alias_fun_spec {@plymio_codi_key_fun_spec,
                                       [
                                         :spec,
                                         :specs,
                                         :fun_specs,
                                         :function_spec,
                                         :function_specs
                                       ]}

      @plymio_codi_key_alias_fun_default {@plymio_codi_key_fun_default,
                                          [:default, :function_default]}

      @plymio_codi_key_alias_typespec_spec_name {@plymio_codi_key_typespec_spec_name,
                                                 [
                                                   :name,
                                                   :spec_name,
                                                   :fun_name,
                                                   :function_name,
                                                   :spec_name
                                                 ]}
      @plymio_codi_key_alias_typespec_spec_args {@plymio_codi_key_typespec_spec_args,
                                                 [
                                                   :args,
                                                   :spec_args,
                                                   :fun_args,
                                                   :function_args,
                                                   :spec_args
                                                 ]}
      @plymio_codi_key_alias_typespec_spec_arity {@plymio_codi_key_typespec_spec_arity,
                                                  [
                                                    :arity,
                                                    :spec_arity,
                                                    :fun_arity,
                                                    :function_arity,
                                                    :spec_arity
                                                  ]}
      @plymio_codi_key_alias_typespec_spec_result {@plymio_codi_key_typespec_spec_result,
                                                   [
                                                     :result,
                                                     :spec_result,
                                                     :fun_result,
                                                     :function_result
                                                   ]}

      @plymio_codi_key_alias_delegate_module {@plymio_codi_key_delegate_module,
                                              [
                                                :to,
                                                :module,
                                                :fun_module,
                                                :fun_mod,
                                                :function_module
                                              ]}
      @plymio_codi_key_alias_delegate_name {@plymio_codi_key_delegate_name, [:as]}
      @plymio_codi_key_alias_delegate_args {@plymio_codi_key_delegate_args, [:args]}
      @plymio_codi_key_alias_delegate_arity {@plymio_codi_key_delegate_arity, [:arity]}

      @plymio_codi_key_alias_delegate_doc {@plymio_codi_key_delegate_doc,
                                           [:doc, :function_doc, :fun_doc]}

      @plymio_codi_key_alias_bang_module {@plymio_codi_key_bang_module,
                                          [:to, :module, :fun_mod, :fun_module, :function_module]}
      @plymio_codi_key_alias_bang_name {@plymio_codi_key_bang_name, [:as]}
      @plymio_codi_key_alias_bang_doc {@plymio_codi_key_bang_doc, [:doc, :fun_doc, :function_doc]}
      @plymio_codi_key_alias_bang_args {@plymio_codi_key_bang_args,
                                        [:args, :fun_args, :function_args]}
      @plymio_codi_key_alias_bang_arity {@plymio_codi_key_bang_arity,
                                         [:arity, :fun_arity, :function_arity]}

      @plymio_codi_key_alias_proxy_name {@plymio_codi_key_proxy_name,
                                         [:proxy, :proxy_names, :proxies]}
      @plymio_codi_key_alias_form {@plymio_codi_key_form, [:forms, :asts, :ast]}

      @plymio_codi_key_alias_transform {@plymio_codi_key_transform, nil}
      @plymio_codi_key_alias_postwalk {@plymio_codi_key_postwalk, [:walk]}

      @plymio_codi_stage_normalise :normalise
      @plymio_codi_stage_express :express
      @plymio_codi_stage_review :review
      @plymio_codi_stage_resolve :resolve

      @plymio_codi_status_done :done
      @plymio_codi_status_active :active
      @plymio_codi_status_dormant :dormant

      @plymio_codi_statuses [
        @plymio_codi_status_done,
        @plymio_codi_status_active,
        @plymio_codi_status_dormant
      ]

      @plymio_codi_doc_type_bang :bang
      @plymio_codi_doc_type_delegate :delegate
    end
  end
end

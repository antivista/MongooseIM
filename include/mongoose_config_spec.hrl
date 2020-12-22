-ifndef(MONGOOSEIM_CONFIG_SPEC_HRL).
-define(MONGOOSEIM_CONFIG_SPEC_HRL, true).

-record(section, {items :: #{toml_key() | default => config_node()},
                  validate_keys = any :: validator(),
                  required = [] :: [toml_key()],
                  validate = any :: section_validator(),
                  process :: option_processor(),
                  format = default :: config_option_format()}).

-record(list, {items :: config_node(),
               validate = any :: list_validator(),
               process :: option_processor(),
               format = default :: config_option_format()}).

-record(option, {type :: option_type(),
                 validate = any :: option_validator(),
                 process :: option_processor(),
                 format = default :: config_option_format()}).

%% -type option_list_processor() :: fun((toml_path(), [option()]) -> option())
%%                                | fun(([option()]) -> option()).

-type option_processor() :: fun((toml_path(), option()) -> option())
                          | fun((option()) -> option()).

-type config_node() :: config_section() | config_list() | config_option().
-type config_section() :: #section{}.
-type config_list() :: #list{}.
-type config_option() :: #option{}.

-type option_value() :: atom() | binary() | string() | float().

-type option_type() :: boolean | binary | string | atom | int_or_infinity
                     | int_or_atom | integer | float.

%% The format describes how the TOML Key and the parsed and processed Value
%% are packed into the resulting list of options.
-type config_format() :: top_level_config_format() | config_option_format().

%% Config record, acl record or 'override' tuple
-type top_level_config_format() ::
      % {override, Value}
        override

      %% Config records, see the type below for details
      | config_record_format()

      %% Uses the provided format for each {K, V} in Value, which has to be a list
      | {foreach, config_record_format()}

      %% Replaces the key with NewKey
      | {config_record_format(), NewKey :: term()}

      %% config record with key = {Tag, Key, Host} when inside host_config
      %%                    key = {Tag, Key, global} at the top level
      | {host_or_global_config, Tag :: term()}

      %% Like above, but for an acl record
      | host_or_global_acl.

%% Config record: #config{} or #local_config{}
-type config_record_format() ::
        %% config record
        config

        %% local_config record
      | local_config

        %% local_config record with key = {Key, Host} when inside host_config
        %% Outside host_config it becomes a list of records - one for each configured host
      | host_local_config.

%% Nested config option - key-value pair or just a value
-type config_option_format() ::
        default      % {Key, Value} for section items, Value for list items
      | item         % only Value
      | skip         % nothing - the item is ignored
      | none         % no formatting - Value must be a list and is injected into the parent list
      | {kv, NewKey :: term()} % {NewKey, Value} - replaces the key with NewKey
      | prepend_key. % {Key, V1, ..., Vn} when Value = {V1, ..., Vn}

-endif.

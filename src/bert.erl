%%% See http://github.com/mojombo/bert.erl for documentation.
%%% MIT License - Copyright (c) 2009 Tom Preston-Werner <tom@mojombo.com>
%%% MIT License - Copyright (c) 2016 Jozsef Berces <jozsef.berces@gmail.com>

-module(bert).
-version('1.1.1').
-author("Tom Preston-Werner").
-author("Jozsef Berces").

-export([encode/1, decode/1]).

-ifdef(TEST).
-include("test/bert_test.erl").
-endif.

%%---------------------------------------------------------------------------
%% Public API

-spec encode(term()) -> binary().

encode(Term) ->
    term_to_binary(encode_term(Term)).

-spec decode(binary()) -> term().

decode(Bin) ->
    decode_term(binary_to_term(Bin)).

%%---------------------------------------------------------------------------
%% Encode

-spec encode_term(term()) -> term().

encode_term(Term) ->
    case Term of
	[] ->
	    {bert, nil};
	true ->
	    {bert, true};
	false ->
	    {bert, false};
	Dict when is_record(Term, dict, 8) ->
	    {bert, dict, dict:to_list(Dict)};
	Dict when is_record(Term, dict, 9) -> % newer dict has 9 elems
	    {bert, dict, dict:to_list(Dict)};
	List when is_list(Term) ->
	    case is_proplist(List) of
		true ->
		    {bert, dict, List};
		false ->
		    lists:map((fun encode_term/1), List)
	    end;
	Tuple when is_tuple(Term) ->
	    TList = tuple_to_list(Tuple),
	    TList2 = lists:map((fun encode_term/1), TList),
	    list_to_tuple(TList2);
	_Else ->
	    Term
    end.

-spec is_proplist(list()) -> boolean().

is_proplist([H | T]) when is_tuple(H) andalso (size(H) == 2) ->
    if T == [] ->
	    true;
       true ->
	    is_proplist(T)
    end;
is_proplist(_) ->
    false.


%%---------------------------------------------------------------------------
%% Decode

-spec decode_term(term()) -> term().

decode_term(Term) ->
    case Term of
	{bert, nil} ->
	    [];
	{bert, true} ->
	    true;
	{bert, false} ->
	    false;
	{bert, dict, Dict} -> % return proplist instead of dict
	    Dict;
	{bert, Other} ->
	    {bert, Other};
	List when is_list(Term) ->
	    lists:map((fun decode_term/1), List);
	Tuple when is_tuple(Term) ->
	    TList = tuple_to_list(Tuple),
	    TList2 = lists:map((fun decode_term/1), TList),
	    list_to_tuple(TList2);
	_Else ->
	    Term
    end.

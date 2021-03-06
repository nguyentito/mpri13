(** The syntax for types and type annotations. *)

open Positions
open Name


(** Basic names **)
(* TODO: check that those types are used everywhere *)
type type_var_name = tname
type type_class_name = tname
type type_constr_name = tname


(** The types are first-order terms. *)
type mltype =
  | TyVar        of position * type_var_name
  | TyApp        of position * type_constr_name * mltype list


type mltype' =
  | TyVar' of type_var_name
  | TyApp' of type_constr_name * mltype' list
 (* TyPunch *)


(** Type schemes. *)
type scheme = TyScheme of type_var_name list * class_predicates * mltype

(* CHECK that this convention (the left one is the class name, the right one is the type variable) 
   matches the actual use of the code *)
and class_predicate = ClassPredicate of type_class_name * type_var_name

and class_predicates = class_predicate list

type instantiation_kind =
  | TypeApplication of mltype list
  | LeftImplicit

(** The following module type specifies the differences
    between the variants of ML we provide in {!IAST} and
    {!XAST}. *)
module type TypingSyntax = sig

  (** The amount of type annotations on bindings differs. *)
  type binding

  val binding
    : Positions.position -> name -> mltype option -> binding

  val destruct_binding
    : binding -> name * mltype option

  (** Type applications are either left implicit or
      explicitly given. *)
  type instantiation

  val instantiation
    : Positions.position -> instantiation_kind -> instantiation

  val destruct_instantiation_as_type_applications
    : instantiation -> mltype list option

  val implicit : bool

end

(** The typing syntax for implicitly typed ML. *)
module ImplicitTyping : TypingSyntax
  with type binding = name * mltype option
  and type instantiation = mltype option

(** The typing syntax for explicitly typed ML. *)
module ExplicitTyping : TypingSyntax
  with type binding = name * mltype
  and type instantiation = mltype list

(** [ntyarrow pos [ity0; ... ityN] oty] returns the type of the shape
    [ity0 -> ... ityN -> oty]. *)
val ntyarrow : position -> mltype list -> mltype -> mltype

(** [destruct_ntyarrow ty] returns [([ity0; ... ityN], oty)] if [ty] has
    the shape [ity0 -> ... ityN -> oty]. Otherwise, it returns [([],
    oty)]. *)
val destruct_ntyarrow : mltype -> mltype list * mltype

(** [destruct_tyarrow ty] returns (ity, oty) if [ty = ity -> oty]. *)
val destruct_tyarrow : mltype -> (mltype * mltype) option

(** Types are internally sorted by kinds. *)
type kind =
  | KStar
  | KArrow of kind * kind

(** [kind_of_arity n] returns the kind for type constructors
    of arity [n]. *)
val kind_of_arity : int -> kind

(** Inverse of kind_of_arity. This function is only partial **)
val arity_of_kind : kind -> int

(** [equivalent t1 t2] returns true if [t1] is equivalent to [t2]. *)
val equivalent : mltype -> mltype -> bool

(** [substitute s ty] returns [ty] on which the substitution [s]
    has been applied. *)
val substitute : (type_var_name * mltype) list -> mltype -> mltype

(************************************************)

module TSet : Set.S with type elt = tname

(** [tset_of_list l] converts a list [l] of variables into a set *)
val tset_of_list : tname list -> TSet.t

(** [type_variable_set t] returns the set of variables which occur in [t],
    i.e. the leaves of its syntax tree *)
val type_variable_set : mltype -> TSet.t

(** non-leaf nodes of the syntax tree *)
val type_constructor_set : mltype -> TSet.t


module LSet : Set.S with type elt = lname

(** Converts a list l of lnames into a set (doesn't check name uniqueness) **)
val lset_of_list : lname list -> LSet.t

(** Converts a list l of lnames into a set while enforcing uniqueness
    If the list names are unique, return Some s (even if the list is empty)
    Else, returns None **)
(* TODO: find a better name! *)
(* TODO: do we want it to work this way (option)? 
   => for error reporting purposes, it would be better to know which identifier is not unique *)
val lset_of_unique_list : lname list -> LSet.t option

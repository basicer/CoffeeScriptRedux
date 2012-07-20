{map, concat, concatMap, nub, union} = require './functional-helpers'
exports = module?.exports ? this

# TODO: stop reusing AssignOp and make a DefaultOp for use in param lists; that was a bad idea in the first place and you should be ashamed
# TODO: make sure all the type signatures are correct
# TODO: expr -> expression

allNodes = {}

createNodes = (subclasses, superclasses = []) ->
  for own className, specs of subclasses then do (className) ->

    superclass = superclasses[0] ? ->
    isCategory = specs? and specs.length is 2
    params =
      if specs?
        switch specs.length
          when 0 then []
          when 1, 2 then specs[0]
      else null
    params ?= superclass::childNodes ? []

    klass = class extends superclass
      constructor:
        if isCategory then ->
        else ->
          for param, i in params
            @[param] = arguments[i]
          @initialise?.apply this, arguments
          this
      className: className
      superclasses: superclasses
    if specs?[0]? then klass::childNodes = specs[0]

    allNodes[className] = klass
    if isCategory then createNodes specs[1], [klass, superclasses...]
    else exports[className] = klass

  return


createNodes
  Nodes: [ [],

    Assignments: [ ['assignee', 'expr'],
      # AssignOp :: Assignables -> Exprs -> AssignOp
      AssignOp: null
      # ClassProtoAssignOp :: ObjectInitialiserKeys -> Exprs -> ClassProtoAssignOp
      ClassProtoAssignOp: null
      # CompoundAssignOp :: CompoundAssignableOps -> Assignables -> Exprs -> CompoundAssignOp
      CompoundAssignOp: [['op', 'assignee', 'expr']]
      # ExistsAssignOp :: Assignables -> Exprs -> ExistsAssignOp
      ExistsAssignOp: null
    ]

    BinOps: [ ['left', 'right'],
      BitOps: [ null
        BitAndOp: null # BitAndOp :: Exprs -> Exprs -> BitAndOp
        BitOrOp: null # BitOrOp :: Exprs -> Exprs -> BitOrOp
        BitXorOp: null # BitXorOp :: Exprs -> Exprs -> BitXorOp
        LeftShiftOp: null # LeftShiftOp :: Exprs -> Exprs -> LeftShiftOp
        SignedRightShiftOp: null # SignedRightShiftOp :: Exprs -> Exprs -> SignedRightShiftOp
        UnsignedRightShiftOp: null # UnsignedRightShiftOp :: Exprs -> Exprs -> UnsignedRightShiftOp
      ]
      ComparisonOps: [ null
        EqOp: null # EQOp :: Exprs -> Exprs -> EQOp
        GTEOp: null # GTEOp :: Exprs -> Exprs -> GTEOp
        GTOp: null # GTOp :: Exprs -> Exprs -> GTOp
        LTEOp: null # LTEOp :: Exprs -> Exprs -> LTEOp
        LTOp: null # LTOp :: Exprs -> Exprs -> LTOp
        NEQOp: null # NEQOp :: Exprs -> Exprs -> NEQOp
      ]
      # Note: A tree of ConcatOp represents interpolation
      ConcatOp: null # ConcatOp :: Exprs -> Exprs -> ConcatOp
      ExistsOp: null # ExistsOp :: Exprs -> Exprs -> ExistsOp
      ExtendsOp: null # ExtendsOp :: Exprs -> Exprs -> ExtendsOp
      InOp: null # InOp :: Exprs -> Exprs -> InOp
      InstanceofOp: null # InstanceofOp :: Exprs -> Exprs -> InstanceofOp
      LogicalOps: [ null
        LogicalAndOp: null # LogicalAndOp :: Exprs -> Exprs -> LogicalAndOp
        LogicalOrOp: null # LogicalOrOp :: Exprs -> Exprs -> LogicalOrOp
      ]
      MathsOps: [ null
        DivideOp: null # DivideOp :: Exprs -> Exprs -> DivideOp
        MultiplyOp: null # MultiplyOp :: Exprs -> Exprs -> MultiplyOp
        RemOp: null # RemOp :: Exprs -> Exprs -> RemOp
        SubtractOp: null # SubtractOp :: Exprs -> Exprs -> SubtractOp
      ]
      OfOp: null # OfOp :: Exprs -> Exprs -> OfOp
      PlusOp: null # PlusOp :: Exprs -> Exprs -> PlusOp
      Range: [['isInclusive', 'left', 'right']] # Range :: bool -> Exprs -> Exprs -> Range
      SeqOp: null # SeqOp :: Exprs -> Exprs -> SeqOp
    ]

    Primitives: [ ['data'],
      Bool: null # Bool :: bool -> Bool
      Identifiers: [ null,
        Identifier: null # Identifier :: string -> Identifier
        GenSym: ['data', 'ns'] # GenSym :: string -> string -> GenSym
      ]
      JavaScript: null # JavaScript :: string -> JavaScript
      Numbers: [null,
        Int: null # Int :: float -> Int
        Float: null # Float :: float -> Float
      ]
      String: null # String :: string -> String
    ]

    Statements: [ [],
      Break: null # Break :: Break
      Continue: null # Continue :: Continue
      Return: [['expr']] # Return :: Exprs -> Return
      Throw: [['expr']] # Throw :: Exprs -> Throw
    ]

    UnaryOps: [ ['expr'],
      BitNotOp: null # BitNotOp :: Exprs -> BitNotOp
      DeleteOp: null # DeleteOp :: MemberAccessOps -> DeleteOp
      DoOp: null # DoOp :: Exprs -> DoOp
      LogicalNotOp: null # LogicalNotOp :: Exprs -> LogicalNotOp
      NewOp: [['ctor', 'arguments']] # NewOp :: Exprs -> [Arguments] -> NewOp
      PreDecrementOp: null # PreDecrementOp :: Exprs -> PreDecrementOp
      PreIncrementOp: null # PreIncrementOp :: Exprs -> PreIncrementOp
      PostDecrementOp: null # PostDecrementOp :: Exprs -> PostDecrementOp
      PostIncrementOp: null # PostIncrementOp :: Exprs -> PostIncrementOp
      TypeofOp: null # TypeofOp :: Exprs -> TypeofOp
      UnaryExistsOp: null # UnaryExistsOp :: Exprs -> UnaryExistsOp
      UnaryNegateOp: null # UnaryNegateOp :: Exprs -> UnaryNegateOp
      UnaryPlusOp: null # UnaryPlusOp :: Exprs -> UnaryPlusOp
    ]

    MemberAccessOps: [ null
      StaticMemberAccessOps: [ ['expr', 'memberName'],
        # MemberAccessOp :: Exprs -> MemberNames -> MemberAccessOp
        MemberAccessOp: null
        # ProtoMemberAccessOp :: Exprs -> MemberNames -> ProtoMemberAccessOp
        ProtoMemberAccessOp: null
        # SoakedMemberAccessOp :: Exprs -> MemberNames -> SoakedMemberAccessOp
        SoakedMemberAccessOp: null
        # SoakedProtoMemberAccessOp :: Exprs -> MemberNames -> SoakedProtoMemberAccessOp
        SoakedProtoMemberAccessOp: null
      ]
      DynamicMemberAccessOps: [ ['expr', 'indexingExpr'],
        # DynamicMemberAccessOp :: Exprs -> Exprs -> DynamicMemberAccessOp
        DynamicMemberAccessOp: null
        # DynamicProtoMemberAccessOp :: Exprs -> Exprs -> DynamicProtoMemberAccessOp
        DynamicProtoMemberAccessOp: null
        # SoakedDynamicMemberAccessOp :: Exprs -> Exprs -> SoakedDynamicMemberAccessOp
        SoakedDynamicMemberAccessOp: null
        # SoakedDynamicProtoMemberAccessOp :: Exprs -> Exprs -> SoakedDynamicProtoMemberAccessOp
        SoakedDynamicProtoMemberAccessOp: null
      ]
    ]

    Functions: [ ['parameters', 'block'],
      Function: null # Function :: [Parameters] -> Maybe Exprs -> Function
      BoundFunction: null # BoundFunction :: [Parameters] -> Maybe Exprs -> BoundFunction
    ]

    FunctionApplications: [ ['function', 'arguments'],
      # FunctionApplication :: Exprs -> [Arguments] -> FunctionApplication
      FunctionApplication: null
      # SoakedFunctionApplication :: Exprs -> [Arguments] -> SoakedFunctionApplication
      SoakedFunctionApplication: null
    ]
    # Super :: [Arguments] -> Super
    Super: [['arguments']]

    # Program :: Maybe Exprs -> Program
    Program: [['block']]
    # Block :: [Statement] -> Block
    Block: [['statements']]
    # Conditional :: Exprs -> Maybe Exprs -> Maybe Exprs -> Conditional
    Conditional: [['condition', 'block', 'elseBlock']]
    # ForIn :: Assignable -> Maybe Assignable -> Exprs -> Exprs -> Maybe Exprs -> Maybe Exprs -> ForIn
    ForIn: [['valAssignee', 'keyAssignee', 'expr', 'step', 'filterExpr', 'block']]
    # ForOf :: bool -> Assignable -> Maybe Assignable -> Exprs -> Maybe Exprs -> Maybe Exprs -> ForOf
    ForOf: [['isOwn', 'keyAssignee', 'valAssignee', 'expr', 'filterExpr', 'block']]
    # Switch :: Maybe Exprs -> [([Exprs], Exprs)] -> Maybe Exprs -> Switch
    Switch: ['expr', 'cases', 'elseBlock']
    # Try :: Exprs -> Maybe Assignable -> Maybe Exprs -> Maybe Exprs -> Try
    Try: [['block', 'catchAssignee', 'catchBlock', 'finallyBlock']]
    # While :: Exprs -> Maybe Exprs -> While
    While: [['condition', 'block']]

    # ArrayInitialiser :: [ArrayInitialiserMembers] -> ArrayInitialiser
    ArrayInitialiser: [['members']]
    # ObjectInitialiser :: [(ObjectInitialiserKeys, Exprs)] -> ObjectInitialiser
    ObjectInitialiser: [['members']]
    # Class:: Maybe Assignable -> Maybe Exprs -> Maybe Exprs -> Class
    Class: ['nameAssignment', 'parent', 'block']
    RegExps: [ null
      # RegExp :: string -> [string] -> RegExp
      RegExp: [['data', 'flags']]
      # HeregExp :: Exprs -> [string] -> HeregExp
      HeregExp: [['expr', 'flags']]
    ]
    Null: null # Null :: Null
    This: null # This :: This
    Undefined: null # Undefined :: Undefined

    # Slice :: Exprs -> bool -> Maybe Exprs -> Maybe Exprs -> Slice
    Slice: ['expr', 'isInclusive', 'left', 'right']

    Rest: [['expr']] # Rest :: Exprs -> Rest
    Spread: [['expr']] # Spread :: Exprs -> Spread
  ]


{
  Nodes, Primitives, CompoundAssignOp, StaticMemberAccessOps, Range,
  ArrayInitialiser, ObjectInitialiser, NegatedConditional, Conditional,
  Identifier, ForOf, Functions, While, GenSym, Class, Block, NewOp
  FunctionApplications, RegExps, RegExp, HeregExp, Super, Slice, Switch
} = allNodes

Nodes.fromJSON = (json) => @[json.nodeType].fromJSON json
Nodes::toJSON = ->
  json = nodeType: @className
  for child in @childNodes
    json[child] = @[child]?.toJSON()
  json
Nodes::fmap = (memo, fn) ->
  for child in @childNodes
    memo = @[child].fmap memo, fn
  fn memo, this
Nodes::instanceof = (ctors...) ->
  # not a fold for efficiency's sake
  for ctor in ctors when @className is ctor::className
    return yes
  no
#Node::r = (@raw) -> this
Nodes::r = -> this
Nodes::p = (@line, @column) -> this
Nodes::generated = no
Nodes::g = ->
  @generated = yes
  this


# TODO: maybe organise/DRY these exceptions better

Primitives::childNodes = []

StaticMemberAccessOps::childNodes = ['expr']
StaticMemberAccessOps::toJSON = ->
  json = Nodes::toJSON.call this
  json.memberName = @memberName
  json

CompoundAssignOp::childNodes = ['assignee', 'expr']
CompoundAssignOp::toJSON = ->
  json = Nodes::toJSON.call this
  json.op = @op::className
  json

Range::childNodes = ['left', 'right']
Range::toJSON = ->
  json = Nodes::toJSON.call this
  json.isInclusive = @isInclusive
  json

ForOf::childNodes = ['keyAssignee', 'valAssignee', 'expr', 'filterExpr', 'block']
ForOf::toJSON = ->
  json = Nodes::toJSON.call this
  json.isOwn = @isOwn
  json

Class::toJSON = ->
  json = Nodes::toJSON.call this
  json.name = @name
  json

RegExp::childNodes = []
RegExp::toJSON = ->
  json = Nodes::toJSON.call this
  json.data = @data
  json.flags = @flags
  json

HeregExp::childNodes = ['expr']
HeregExp::toJSON = ->
  json = Nodes::toJSON.call this
  json.flags = @flags
  json

Slice::childNodes = ['expr', 'left', 'right']
Slice::toJSON = ->
  json = Nodes::toJSON.call this
  json.isInclusive = @isInclusive
  json


ArrayInitialiser::childNodes = []
ArrayInitialiser::toJSON = ->
  json = Nodes::toJSON.call this
  json.members = (m.toJSON() for m in @members)
  json

Block::childNodes = []
Block::toJSON = ->
  json = Nodes::toJSON.call this
  json.statements = (s.toJSON() for s in @statements)
  json

Functions::childNodes = ['block']
Functions::toJSON = ->
  json = Nodes::toJSON.call this
  json.parameters = (p.toJSON() for p in @parameters)
  json

FunctionApplications::childNodes = ['function']
FunctionApplications::toJSON = ->
  json = Nodes::toJSON.call this
  json.arguments = (a.toJSON() for a in @arguments)
  json

NewOp::childNodes = ['ctor']
NewOp::toJSON = FunctionApplications::toJSON

ObjectInitialiser::childNodes = []
ObjectInitialiser::toJSON = ->
  json = Nodes::toJSON.call this
  json.members = for [key, expr] in @members
    [key.toJSON(), expr.toJSON()]
  json

Super::childNodes = []
Super::toJSON = FunctionApplications::toJSON

# TODO: this doesn't account for the cases
Switch::childNodes = ['expr', 'elseBlock']
Switch::toJSON = ->
  json = Nodes::toJSON.call this
  json.cases = for [conds, block] in @cases
    [c.toJSON() for c in conds, block.toJSON()]
  json


Block::wrap = (s) -> new Block(if s? then [s] else []).r(s.raw).p(s.line, s.column)

Class::initialise = ->
  @name =
    if @nameAssignment?
      # poor man's pattern matching
      switch @nameAssignment.className
        when Identifier::className
          @nameAssignment.data
        when MemberAccessOp::className, ProtoMemberAccessOp::className, SoakedMemberAccessOp::className, SoakedProtoMemberAccessOp::className
          @nameAssignment.memberName
        else null
    else null

GenSym::initialise = -> @ns ?= ''

ObjectInitialiser::keys = -> map @members ([key, val]) -> key
ObjectInitialiser::vals = -> map @members ([key, val]) -> val

RegExps::initialise = (_, flags) ->
  @flags = {}
  for flag in ['g', 'i', 'm', 'y']
    @flags[flag] = flag in flags


# Note: This only represents the original syntactic specification as an
# "unless". The node should be treated in all other ways as a Conditional.
# NegatedConditional :: Exprs -> Maybe Exprs -> Maybe Exprs -> NegatedConditional
class exports.NegatedConditional extends Conditional

# Note: This only represents the original syntactic specification as an
# "until". The node should be treated in all other ways as a While.
# NegatedWhile :: Exprs -> Maybe Exprs -> NegatedWhile
class exports.NegatedWhile extends While

# Note: This only represents the original syntactic specification as a "loop".
# The node should be treated in all other ways as a While.
# Loop :: Maybe Exprs -> Loop
class exports.Loop extends While
  constructor: (block) -> super (new Bool true).g(), block

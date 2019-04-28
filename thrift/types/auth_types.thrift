namespace rb ThriftDefs.AuthTypes

typedef string Uuid

enum EntityRole {
  GUEST = 0,
  USER = 1,
}

struct Entity {
  1: optional Uuid uuid,
  2: EntityRole role,
}

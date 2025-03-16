extends Resource
class_name ObjectData

enum ObjectType {
    COIN,
    GRENADE,
    HEALTH_POTION
}

var objects : Dictionary[ObjectType, Array] = {
    ObjectType.COIN: [],
    ObjectType.GRENADE: [],
    ObjectType.HEALTH_POTION: []
}

func print_objects():
    print("Coins: ", objects[ObjectType.COIN])
    print("Grenades: ", objects[ObjectType.GRENADE])
    print("Health Potions: ", objects[ObjectType.HEALTH_POTION])
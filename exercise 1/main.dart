// Abstract Animal class
abstract class Animal {
  String name;
  int legs;

  // Constructor
  Animal(this.name, this.legs);

  // Abstract method - must be implemented by subclasses
  void makeSound();

  // Regular method
  void displayInfo() {
    print('$name has $legs legs');
  }
}

// Dog subclass
class Dog extends Animal {
  // Dog constructor - calls super constructor with 4 legs
  Dog(String name) : super(name, 4);

  @override
  void makeSound() {
    print('$name says Woof!');
  }
}

// Cat subclass
class Cat extends Animal {
  // Cat constructor - calls super constructor with 4 legs
  Cat(String name) : super(name, 4);

  @override
  void makeSound() {
    print('$name says Meow!');
  }
}

void main() {
  // Create a list of animals (polymorphism)
  List<Animal> animals = [
    Dog('Buddy'),
    Cat('Whiskers'),
  ];

  // Iterate through the list and make each animal sound
  print('--- Animal Sounds ---');
  for (var animal in animals) {
    animal.makeSound();  // Polymorphic call
  }
  
  // Optional: Display additional info
  print('\n--- Additional Info ---');
  for (var animal in animals) {
    animal.displayInfo();
  }
  
  // Alternative using forEach with lambda
  print('\n--- Using forEach Lambda ---');
  animals.forEach((animal) => animal.makeSound());
}
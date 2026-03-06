// Define the Drawable interface (abstract class in Dart)
abstract class Drawable {
  void draw();  // Abstract method
}

// Circle class implementing Drawable
class Circle implements Drawable {
  int radius;
  
  Circle(this.radius);
  
  @override
  void draw() {
    print('***');
    print('*   *');
    print('***');
  }
}

// Square class implementing Drawable
class Square implements Drawable {
  int sideLength;
  
  Square(this.sideLength);
  
  @override
  void draw() {
    print('***');
    print('* *');
    print('***');
  }
}

// Bonus: Triangle class (optional additional shape)
class Triangle implements Drawable {
  int base;
  
  Triangle(this.base);
  
  @override
  void draw() {
    print('  *  ');
    print(' * * ');
    print('*****');
  }
}

void main() {
  // Create individual shapes
  print('=== DRAWING INDIVIDUAL SHAPES ===');
  
  Circle myCircle = Circle(5);
  print('Circle (radius: ${myCircle.radius}):');
  myCircle.draw();
  
  print('\nSquare (side: ${Square(4).sideLength}):');
  Square mySquare = Square(4);
  mySquare.draw();

  print('\n=== DRAWING WITH POLYMORPHISM ===');
  // Create a list of drawable shapes
  List<Drawable> shapes = [
    Circle(3),
    Square(6),
    Triangle(5),
    Circle(2),
    Square(8),
  ];

  // Draw all shapes using the interface
  print('Drawing all shapes:');
  for (var shape in shapes) {
    print('');  // Empty line for spacing
    shape.draw();
  }

  print('\n=== USING LAMBDA WITH FOREACH ===');
  shapes.forEach((shape) {
    print('\nNext shape:');
    shape.draw();
  });

  print('\n=== USING LAMBDA WITH MAP ===');
  // Create descriptions using map
  var descriptions = shapes.map((shape) {
    if (shape is Circle) return 'Circle (radius: ${shape.radius})';
    if (shape is Square) return 'Square (side: ${shape.sideLength})';
    if (shape is Triangle) return 'Triangle (base: ${(shape as Triangle).base})';
    return 'Unknown shape';
  }).toList();
  
  descriptions.forEach((desc) => print(desc));

  print('\n=== DEMONSTRATING INTERFACE CONTRACT ===');
  // Function that accepts any Drawable
  void drawShape(Drawable shape) {
    print('Drawing:');
    shape.draw();
  }
  
  drawShape(Circle(10));
  drawShape(Square(3));
}
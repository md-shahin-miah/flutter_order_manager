import 'dart:math';

class RandomNameGenerator {
  static const List<String> _firstNames = [
    'Alice', 'Bob', 'Charlie', 'David', 'Eve', 'Frank', 'Grace', 'Henry', 'Ivy',
    'Jack', 'Katie', 'Liam', 'Mia', 'Noah', 'Olivia', 'Peter', 'Quinn', 'Ryan',
    'Sophia', 'Thomas', 'Uma', 'Victor', 'Willow', 'Xavier', 'Yara', 'Zane',
    'Aisha', 'Omar', 'Fatima', 'Karim', 'Layla', 'Nadia', 'Salim', 'Zara',
    'Akira', 'Kenji', 'Sakura', 'Hiroshi', 'Yumi', 'Ren', 'Ayumi', 'Daiki',
    'Isabella', 'William', 'James', 'Benjamin', 'Lucas', 'Mason', 'Ethan', 'Daniel',
    'Matthew', 'Joseph', 'Christopher', 'Andrew', 'Samuel', 'Anthony', 'Alexander',
    'Michael', 'Emily', 'Elizabeth', 'Abigail', 'Madison', 'Charlotte', 'Harper',
    'Amelia', 'Evelyn', 'Hannah', 'Scarlett', 'Victoria', 'Avery', 'Sofia',
  ];

  static const List<String> _lastNames = [
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
    'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
    'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson',
    'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker',
    'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill',
    'Flores', 'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell',
    'Mitchell', 'Carter', 'Roberts', 'Gomez', 'Phillips', 'Evans', 'Turner',
    'Diaz', 'Parker', 'Cruz', 'Edwards', 'Collins', 'Reyes', 'Stewart', 'Morris',
    'Morales', 'Murphy', 'Cook', 'Rogers', 'Gutierrez', 'Ortiz', 'Morgan', 'Cooper',
    'Peterson', 'Bailey', 'Reed', 'Kelly', 'Howard', 'Ward', 'Cox', 'Richardson',
    'Watson', 'Brooks', 'Wood', 'James', 'Bennett', 'Gray', 'Mendoza', 'Ruiz',
    'Hughes', 'Price', 'Alvarez', 'Castillo', 'Sanders', 'Patel', 'Myers', 'Long',
    'Ross', 'Foster', 'Jimenez',
  ];

  static String generateRandomName() {
    final random = Random();
    final firstName = _firstNames[random.nextInt(_firstNames.length)];
    final lastName = _lastNames[random.nextInt(_lastNames.length)];
    return '$firstName $lastName';
  }

  static String generateRandomFirstName() {
    final random = Random();
    return _firstNames[random.nextInt(_firstNames.length)];
  }

  static String generateRandomLastName() {
    final random = Random();
    return _lastNames[random.nextInt(_lastNames.length)];
  }
}

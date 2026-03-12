# Implementation Plan

- [x] 1. Set up component pooling infrastructure





  - Create generic `ComponentPool<T>` class in `lib/component_pool.dart`
  - Implement `acquire()`, `release()`, and `clear()` methods
  - Add pool statistics tracking (active count, available count)
  - Create `Poolable` interface for components that support pooling
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 2. Refactor Player to use SpriteComponent





  - Rename `lib/player.dart` to `lib/player_component.dart`
  - Change `Player` class to extend `SpriteComponent` instead of `PositionComponent`
  - Remove manual `render()` method and use Flame's sprite rendering
  - Add `DragCallbacks` mixin for direct input handling on component
  - Add `RectangleHitbox` for collision detection
  - Implement `onDragUpdate()` for player movement
  - Update sprite loading to use `Sprite.load()` utility
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 10.2_

- [x] 3. Refactor Bullet to use SpriteComponent with pooling





  - Rename `lib/bullet.dart` to `lib/bullet_component.dart`
  - Change `Bullet` class to extend `SpriteComponent` and implement `Poolable`
  - Remove manual `render()` method
  - Add `RectangleHitbox` for collision detection
  - Add `CollisionCallbacks` mixin and implement `onCollision()`
  - Implement `reset()` method for pool reuse
  - Implement `returnToPool()` method
  - Update `destroy()` to use pooling instead of removal
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 9.1, 9.2_

- [x] 4. Refactor Meteor to use SpriteComponent with pooling





  - Rename `lib/meteor.dart` to `lib/meteor_component.dart`
  - Change `Meteor` class to extend `SpriteComponent` and implement `Poolable`
  - Remove manual `render()` method
  - Add `CircleHitbox` for accurate collision detection
  - Add `CollisionCallbacks` mixin and implement `onCollision()`
  - Implement `reset()` method for pool reuse with position and speed parameters
  - Implement `returnToPool()` method
  - Update `destroy()` to use pooling
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.3, 9.1, 9.2_

- [x] 5. Refactor PowerUp to use SpriteComponent





  - Rename `lib/power_up.dart` to `lib/power_up_component.dart`
  - Change `PowerUp` class to extend `SpriteComponent`
  - Remove manual `render()` method
  - Add `CircleHitbox` for collision detection
  - Add `CollisionCallbacks` mixin and implement `onCollision()`
  - Update sprite loading for both power-up types
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.3_

- [x] 6. Implement Flame's collision detection system





  - Remove manual `checkCollisions()` method from `SkyDefenderGame`
  - Remove `toRect()` helper methods from all components
  - Implement `onCollision()` callbacks in Player component for meteor and power-up collisions
  - Implement `onCollision()` callbacks in Bullet component for meteor collisions
  - Implement `onCollision()` callbacks in Meteor component for bullet collisions
  - Add collision handler methods to game: `onPlayerHitMeteor()`, `onPlayerCollectPowerUp()`
  - Test collision accuracy matches previous implementation
  - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 7. Replace custom particle system with Flame particles









  - Remove `lib/particle.dart` and `lib/particle_effect.dart` files
  - Update `spawnParticleEffect()` method in game to use Flame's `ParticleSystemComponent`
  - Implement particle generation using `Particle.generate()` with `AcceleratedParticle`
  - Use `CircleParticle` for particle rendering
  - Add gravity effect to particles using acceleration
  - Remove manual particle lifecycle management
  - Test visual parity with previous particle effects
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 8. Implement TimerComponent for game timers








  - Create `meteorSpawnTimer` as `TimerComponent` in game
  - Create `bulletFireTimer` as `TimerComponent` in game
  - Create `powerUpSpawnTimer` as `TimerComponent` in game
  - Remove manual timer variables (`meteorSpawnTimer`, `bulletFireTimer`, `powerUpSpawnTimer` doubles)
  - Remove manual timer updates from `update()` method
  - Implement timer callbacks for spawning meteors, firing bullets, and spawning power-ups
  - Update timer periods dynamically for difficulty changes and rapid fire
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 9. Implement screen shake using Flame's effect system





  - Remove manual camera shake variables (`_cameraOffset`, `_shakeIntensity`, `_shakeDuration`)
  - Remove manual camera shake update logic from `update()` method
  - Implement `triggerScreenShake()` using `MoveEffect` with `SequenceEffect`
  - Create sequence of random move effects for shake animation
  - Add final move effect to return camera to center
  - Test shake intensity and duration match previous implementation
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 8.1, 8.4_

- [x] 10. Initialize component pools in game





  - Add `bulletPool` property to `SkyDefenderGame`
  - Add `meteorPool` property to `SkyDefenderGame`
  - Initialize pools in `onLoad()` with appropriate initial and max sizes
  - Update `fireBullet()` to acquire bullets from pool
  - Update `spawnMeteor()` to acquire meteors from pool
  - Update `restartGame()` and `goToStartScreen()` to clear pools
  - Add pool cleanup in `onRemove()`
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 11. Optimize sprite loading and sharing





  - Load common sprites once at game level in `onLoad()`
  - Create `meteorSprite`, `bulletSprite`, `playerSprite` properties in game
  - Update components to reuse shared sprite instances instead of loading individually
  - Remove duplicate sprite loading from component `onLoad()` methods
  - Maintain fallback sprite generation for missing assets
  - _Requirements: 6.1, 6.3, 6.4_

- [x] 12. Refactor input handling to component level





  - Remove `onPanStart()` and `onPanUpdate()` from game level
  - Implement drag handling directly in Player component using `DragCallbacks`
  - Remove `TapDetector` and `PanDetector` mixins from game if no longer needed
  - Test input responsiveness matches previous implementation
  - _Requirements: 10.1, 10.2, 10.3_

- [x] 13. Update game imports and references





  - Update all imports from `player.dart` to `player_component.dart`
  - Update all imports from `meteor.dart` to `meteor_component.dart`
  - Update all imports from `bullet.dart` to `bullet_component.dart`
  - Update all imports from `power_up.dart` to `power_up_component.dart`
  - Remove imports for deleted `particle.dart` and `particle_effect.dart`
  - Update class name references throughout codebase
  - _Requirements: 7.1, 7.2, 7.3_

- [x] 14. Implement proper component lifecycle





  - Ensure all components initialize resources in `onLoad()` not constructors
  - Ensure all components use `onMount()` for game-dependent initialization where needed
  - Ensure all components clean up resources in `onRemove()`
  - Verify all components properly await `onLoad()` completion
  - Add proper disposal of timers and effects in game `onRemove()`
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 15. Add component priority for render ordering





  - Set priority on Player component to render on top
  - Set priority on UI components appropriately
  - Remove any manual z-ordering logic if present
  - Test visual layering matches previous implementation
  - _Requirements: 6.4_

- [x] 16. Performance testing and optimization











  - Create performance benchmark test measuring frame times
  - Create test measuring GC events during gameplay
  - Create test measuring memory usage with many entities
  - Profile collision detection performance
  - Profile particle system performance
  - Compare metrics before and after refactoring
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 17. Update documentation










  - Update README.md with new architecture information
  - Document component pooling system
  - Document Flame features being used
  - Add performance improvement metrics
  - Update code comments for refactored components
  - _Requirements: 7.1, 7.2, 7.3_

- [ ] 18. Integration testing
















  - Test complete gameplay flow with refactored components
  - Verify collision detection accuracy
  - Verify particle effects visual quality
  - Verify screen shake feels the same
  - Verify input responsiveness
  - Test game restart and return to menu functionality
  - Test pause/resume with new timer system
  - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1, 10.1_

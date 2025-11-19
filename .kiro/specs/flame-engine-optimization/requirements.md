# Requirements Document

## Introduction

This specification outlines improvements to Sky Defender's use of the Flame game engine. While the game currently uses Flame 1.30.1, it's not leveraging many of Flame's powerful built-in features. This spec focuses on replacing custom implementations with Flame's optimized components, improving performance, reducing code complexity, and making the game more maintainable.

## Glossary

- **Flame Engine**: A 2D game engine built on top of Flutter, providing game-specific components and utilities
- **Component System**: Flame's entity-component architecture for game objects
- **SpriteComponent**: Flame's built-in component for rendering sprites with automatic lifecycle management
- **ParticleComponent**: Flame's optimized particle system for visual effects
- **CollisionDetection**: Flame's built-in collision detection system using hitboxes
- **Effect System**: Flame's animation and effect system for component transformations
- **TimerComponent**: Flame's built-in timer for scheduled events
- **Game Loop**: The core update-render cycle managed by Flame
- **Sky Defender**: The game system being optimized

## Requirements

### Requirement 1: Replace Custom Components with Flame Components

**User Story:** As a developer, I want to use Flame's built-in components instead of custom implementations, so that the codebase is more maintainable and benefits from Flame's optimizations.

#### Acceptance Criteria

1. WHEN implementing game entities, THE Sky Defender SHALL use SpriteComponent for Player, Meteor, Bullet, and PowerUp instead of PositionComponent with manual sprite rendering
2. WHEN rendering sprites, THE Sky Defender SHALL leverage SpriteComponent's automatic sprite management and rendering
3. WHEN creating game objects, THE Sky Defender SHALL use Flame's component lifecycle methods (onLoad, onMount, onRemove) consistently
4. WHEN managing component state, THE Sky Defender SHALL utilize Flame's built-in properties (position, size, anchor, angle) without custom wrappers
5. WHERE sprite loading is required, THE Sky Defender SHALL use Flame's sprite loading utilities with proper error handling

### Requirement 2: Implement Flame's Collision Detection System

**User Story:** As a developer, I want to use Flame's collision detection system, so that collision handling is more efficient and accurate than manual rectangle overlap checks.

#### Acceptance Criteria

1. WHEN detecting collisions, THE Sky Defender SHALL use Flame's HasCollisionDetection mixin with proper hitbox components
2. WHEN game entities collide, THE Sky Defender SHALL implement onCollision and onCollisionEnd callbacks instead of manual overlap checking
3. WHEN defining collision boundaries, THE Sky Defender SHALL use RectangleHitbox or CircleHitbox components attached to game entities
4. WHEN processing collisions, THE Sky Defender SHALL leverage Flame's collision detection system to automatically detect and notify colliding components
5. IF collision groups are needed, THEN THE Sky Defender SHALL use Flame's collision layer system to filter collision checks

### Requirement 3: Replace Custom Particle System with Flame Particles

**User Story:** As a developer, I want to use Flame's particle system, so that visual effects are more performant and feature-rich than the custom implementation.

#### Acceptance Criteria

1. WHEN creating explosion effects, THE Sky Defender SHALL use Flame's ParticleSystemComponent instead of custom ParticleEffect
2. WHEN spawning particles, THE Sky Defender SHALL use Flame's built-in particle generators (CircleParticle, MovingParticle, AcceleratedParticle)
3. WHEN animating particles, THE Sky Defender SHALL leverage Flame's particle behaviors (CurvedParticle, ComposedParticle) for complex effects
4. WHEN particles expire, THE Sky Defender SHALL rely on Flame's automatic particle lifecycle management
5. WHERE multiple particle types are needed, THE Sky Defender SHALL compose particles using Flame's particle composition system

### Requirement 4: Implement Flame's Effect System

**User Story:** As a developer, I want to use Flame's effect system for animations, so that screen shake, button animations, and transitions are handled by the engine's optimized system.

#### Acceptance Criteria

1. WHEN implementing screen shake, THE Sky Defender SHALL use MoveEffect or ScaleEffect on the camera instead of manual offset calculations
2. WHEN animating UI elements, THE Sky Defender SHALL use Flame's effect system (ScaleEffect, OpacityEffect, RotateEffect) instead of Flutter AnimationControllers where appropriate
3. WHEN creating sequential animations, THE Sky Defender SHALL use SequenceEffect to chain multiple effects
4. WHEN effects complete, THE Sky Defender SHALL use effect callbacks for triggering subsequent actions
5. WHERE effects need to repeat, THE Sky Defender SHALL use Flame's effect repeat and reverse capabilities

### Requirement 5: Use Flame's Timer System

**User Story:** As a developer, I want to use Flame's timer components, so that time-based events are managed consistently by the engine.

#### Acceptance Criteria

1. WHEN scheduling periodic events, THE Sky Defender SHALL use TimerComponent instead of manual timer variables
2. WHEN implementing cooldowns, THE Sky Defender SHALL use Timer.periodic for repeating actions like meteor spawning and bullet firing
3. WHEN power-ups have durations, THE Sky Defender SHALL use Timer for automatic expiration instead of manual countdown
4. WHEN timers complete, THE Sky Defender SHALL use timer callbacks for triggering events
5. WHERE timers need to pause, THE Sky Defender SHALL leverage Flame's automatic timer pausing when game is paused

### Requirement 6: Optimize Component Rendering

**User Story:** As a developer, I want to leverage Flame's rendering optimizations, so that the game performs better with many on-screen entities.

#### Acceptance Criteria

1. WHEN rendering sprites, THE Sky Defender SHALL use Flame's sprite batching capabilities for improved performance
2. WHEN components are off-screen, THE Sky Defender SHALL use Flame's automatic culling to skip rendering
3. WHEN multiple entities share sprites, THE Sky Defender SHALL reuse loaded Sprite instances instead of loading duplicates
4. WHEN rendering order matters, THE Sky Defender SHALL use component priority property instead of manual z-ordering
5. WHERE rendering is expensive, THE Sky Defender SHALL use Flame's HasPaint mixin for optimized paint object management

### Requirement 7: Implement Proper Component Lifecycle

**User Story:** As a developer, I want to follow Flame's component lifecycle patterns, so that resources are properly managed and memory leaks are prevented.

#### Acceptance Criteria

1. WHEN components are created, THE Sky Defender SHALL initialize resources in onLoad instead of constructors
2. WHEN components are added to game, THE Sky Defender SHALL use onMount for game-dependent initialization
3. WHEN components are removed, THE Sky Defender SHALL clean up resources in onRemove
4. WHEN components need game reference, THE Sky Defender SHALL use HasGameReference mixin consistently
5. WHERE async initialization is needed, THE Sky Defender SHALL properly await onLoad completion

### Requirement 8: Use Flame's Camera System

**User Story:** As a developer, I want to use Flame's camera system properly, so that viewport management and camera effects are handled correctly.

#### Acceptance Criteria

1. WHEN implementing screen shake, THE Sky Defender SHALL use camera effects instead of manual position manipulation
2. WHEN managing viewport, THE Sky Defender SHALL use CameraComponent with proper world and viewport configuration
3. WHEN camera moves, THE Sky Defender SHALL use camera follow behaviors for smooth tracking
4. WHEN applying camera effects, THE Sky Defender SHALL use Flame's camera effect system
5. WHERE camera bounds are needed, THE Sky Defender SHALL use camera viewport constraints

### Requirement 9: Implement Component Pooling

**User Story:** As a developer, I want to use object pooling for frequently created/destroyed entities, so that garbage collection overhead is reduced.

#### Acceptance Criteria

1. WHEN spawning bullets frequently, THE Sky Defender SHALL implement component pooling to reuse bullet instances
2. WHEN meteors are destroyed, THE Sky Defender SHALL return them to a pool instead of creating new instances
3. WHEN particles are spawned, THE Sky Defender SHALL use pooled particle components where appropriate
4. WHEN pool is empty, THE Sky Defender SHALL create new instances as needed
5. WHERE pooling improves performance, THE Sky Defender SHALL implement pool size limits to prevent unbounded growth

### Requirement 10: Leverage Flame's Input System

**User Story:** As a developer, I want to use Flame's input handling properly, so that touch and drag events are processed efficiently.

#### Acceptance Criteria

1. WHEN handling touch input, THE Sky Defender SHALL use TapCallbacks mixin on specific components instead of global game-level detection
2. WHEN implementing drag controls, THE Sky Defender SHALL use DragCallbacks on the player component
3. WHEN detecting gestures, THE Sky Defender SHALL leverage Flame's gesture detection system
4. WHEN input needs priority, THE Sky Defender SHALL use Flame's input priority system
5. WHERE multiple components handle input, THE Sky Defender SHALL use proper event propagation and consumption

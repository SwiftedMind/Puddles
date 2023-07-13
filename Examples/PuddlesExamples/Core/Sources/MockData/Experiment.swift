import Foundation
import Models
import IdentifiedCollections

extension Mock {
    public enum Experiment {
        public static var all: IdentifiedArrayOf<Models.Experiment> {
            [
                Models.Experiment(title: "The Invisibility Cloak for Robots", description: "An ingenious scientist developed an invisibility cloak specifically for robots. The only problem? Robots don't care about being seen. They have no concept of embarrassment, and now there's a bunch of machinery bumping into everything because humans can't see them."),
                Models.Experiment(title: "The Universal Remote for Black Holes", description: "A groundbreaking device that supposedly controls black holes - change channels, adjust volume, even put them on mute. Unfortunately, the batteries aren't included, and the power required is equal to the energy of a supernova. Not to mention, black holes don't have channels."),
                Models.Experiment(title: "Zero-Calorie Matter Replicator", description: "A device designed to create zero-calorie versions of any food. It works perfectly but makes the food taste like cardboard. The creator lost a ton of weight because they lost interest in eating."),
                Models.Experiment(title: "The Intergalactic Space-Cleaning Vacuum", description: "A powerful vacuum cleaner designed to tidy up the universe by sucking in space debris. It ended up removing the 'space' in the 'space-time continuum', leading to some very perplexed physicists."),
                Models.Experiment(title: "Teleporting Toilet", description: "Designed to address the pressing question of 'what if I could teleport to work while on the loo?' The creator successfully teleported but materialized at the office without his pants. He is now working on a matching teleporting wardrobe.")
            ]
        }

        public static func mock(index: Int = 0) -> Models.Experiment {
            all[index % all.count]
        }
    }
}

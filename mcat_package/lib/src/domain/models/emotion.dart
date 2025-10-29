enum Emotion {
surprise,
happy,
neutral,
sad,
fear,
angry,
disgust,
}


extension EmotionX on Emotion {
String get label => switch (this) {
Emotion.surprise => 'Surprise',
Emotion.happy => 'Happy',
Emotion.neutral => 'Neutral',
Emotion.sad => 'Sad',
Emotion.fear => 'Fear',
Emotion.angry => 'Angry',
Emotion.disgust => 'Disgust',
};
}
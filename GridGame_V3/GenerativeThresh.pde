//file: GenerativeThresh
class ThresholdGenerator {

  int getGainThreshold(int score, int round) {
    return constrain(10 - round - score / 20, 2, 10);
  }

  int getLossThreshold(int score, int round) {
    return constrain(2 + round + score / 20, 2, 10);
  }
}

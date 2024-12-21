import 'package:parla_italiano/dbModels/appUser.dart';
import 'package:parla_italiano/games/generic/genericGame.dart';
import 'package:parla_italiano/models/vocabulary.dart';

class ClassicGame extends GenericGame{

  String? gameID;
  List<Vocabulary> vocabularies = [];
  AppUser player1;
  AppUser player2;
  AppUser actualPlayer;
  List<int> player1Points;
  List<int> player2Points;
  int actualRound;
  int totalRounds;
  List<bool> italianToGerman = [];
  bool finished;

  List<String> player1Responses = List<String>.filled(30, '');
  List<String> player2Responses = List<String>.filled(30, '');
  List<String> questions = [];
  List<String> solutions = [];
  late int currentIndex;
  late int neededVocabularies;

  ClassicGame({required this.gameID, required this.player1, required this.player2, required this.actualPlayer, required this.player1Points, required this.player2Points, required this.actualRound, required this.totalRounds, required this.vocabularies, required this.italianToGerman, required this.finished}) {
    neededVocabularies = vocabularies.length;
    currentIndex = (actualRound - 1) * (neededVocabularies / totalRounds).toInt();
    for (int i = 0; i < vocabularies.length; i++){
      Vocabulary vocabulary = vocabularies[i];
      bool italToGerman = italianToGerman[i];
      if (italToGerman){
        questions.add(vocabulary.italian);
        solutions.add(vocabulary.german);
      } else {
        questions.add(vocabulary.german);
        solutions.add(vocabulary.italian);
      }
    }
  }

  bool validateAnswer(String answer){
    bool correct = answer == solutions[currentIndex];
    if (actualPlayer.userID == player1.userID){
      player1Responses[currentIndex] = answer;
      correct ? player1Points[actualRound - 1] = player1Points[actualRound - 1] + 1 : player1Points[actualRound - 1] = player1Points[actualRound - 1];
    } else {
      player2Responses[currentIndex] = answer;
      correct ? player2Points[actualRound - 1] = player2Points[actualRound - 1] + 1 : player2Points[actualRound - 1] = player2Points[actualRound - 1]; 
    }
    return correct;
  }

  bool setNextWord(){
    if (currentIndex < ((neededVocabularies/totalRounds) * (actualRound) -1)){
      currentIndex = currentIndex + 1;
      return true;
    } else {
      return false;
    }
  }

  String getActualQuestion(){
    return questions[currentIndex];
  }

  List<String> getVocabularyIDs(){
    List<String> ids = [];
    for(Vocabulary vocabulary in vocabularies){
      ids.add(vocabulary.italian);
    }
    return ids;
  }

  bool setNextRound(){
    if (actualPlayer.userID == player2.userID && actualRound == 3){
      finished = true;
      return false;
    }else if (actualRound % 2 == 0){
      currentIndex = currentIndex + 1;
      actualPlayer.userID == player2.userID ? actualPlayer = player1 : actualRound = actualRound + 1;
      return true;
    } else {
      currentIndex = currentIndex + 1;
      actualPlayer.userID == player1.userID ? actualPlayer = player2 : actualRound = actualRound + 1;
      return true;
    }
  }
    
  List<WrongWordResponse> getFalseWordsInRound(){
    List<WrongWordResponse> falseWords = [];
    for (int i = (actualRound - 1) * (neededVocabularies / totalRounds).toInt(); i < (actualRound ) * (neededVocabularies / totalRounds); i++){
      if (actualPlayer.userID == player1.userID){
        if (player1Responses[i] != solutions[i]){
          bool fromItalianToGerman;
          questions[i] == vocabularies[i].italian ? fromItalianToGerman = true : fromItalianToGerman = false;
          falseWords.add(WrongWordResponse(vocabulary: vocabularies[i], givenRepsone: player1Responses[i], fromItalianToGerman: fromItalianToGerman));
        }
      } else {
        if (player2Responses[i] != solutions[i]){
          bool fromItalianToGerman;
          questions[i] == vocabularies[i].italian ? fromItalianToGerman = true : fromItalianToGerman = false;
          falseWords.add(WrongWordResponse(vocabulary: vocabularies[i], givenRepsone: player2Responses[i], fromItalianToGerman: fromItalianToGerman));
        }
      }
    }
    return falseWords;
  }

  @override
  List<int> getPlayersTotalPoints(){
    int player1PointsTotal = 0;
    int player2PointsTotal = 0;
    for (int value in player1Points){
      player1PointsTotal = player1PointsTotal + value;
    }
    for (int value in player2Points){
      player2PointsTotal = player2PointsTotal + value;
    }
    return [player1PointsTotal, player2PointsTotal];
  }

  List<AppUser> getPlayers(){
    return [player1, player2];
  }

  int getActualRound(){
    return actualRound;
  }

  AppUser getActualPlayer(){
    return actualPlayer;
  }

  bool isFinished(){
    return finished;
  }

}

class WrongWordResponse{

  bool fromItalianToGerman;
  Vocabulary vocabulary;
  String givenRepsone;

  WrongWordResponse({required this.vocabulary, required this.givenRepsone, required this.fromItalianToGerman});
}
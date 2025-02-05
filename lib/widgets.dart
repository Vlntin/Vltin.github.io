import 'dart:math';

import 'package:flutter/material.dart';
import 'package:parla_italiano/handler/userHandler.dart';
import 'package:parla_italiano/handler/vocabularyHandler.dart';
import 'package:parla_italiano/dbModels/DBtable.dart';
import 'package:parla_italiano/globals/globalData.dart' as globalData;

import 'package:go_router/go_router.dart';

import 'package:parla_italiano/handler/speaker.dart';
import 'package:parla_italiano/models/vocabulary.dart';
import 'package:parla_italiano/models/vocabularyTable.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:html';
import 'dart:ui';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:parla_italiano/constants/colors.dart' as colors;
import 'package:parla_italiano/routes.dart' as routes;

class VocabularyWidget extends StatefulWidget {
  const VocabularyWidget(this.id, this.italian, this.german, this.additional, {super.key});

  final String additional;
  final String italian;
  final String german;
  final String id;

  @override
  State<VocabularyWidget> createState() => _VocabularyWidgetState();
}
class _VocabularyWidgetState extends State<VocabularyWidget> {

  bool pressAttention = false;
  
  @override
  Widget build(BuildContext context) {
    bool pressAttention = globalData.vocabularyRepo!.isVocabularyInFavorites(widget.id);
    return Padding(
        padding: EdgeInsets.all(0),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    widget.italian,
                    style: TextStyle(
                      fontSize: 12,
                    )
                  ),
                ) ,
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    widget.german,
                    style: TextStyle(
                      fontSize: 12,
                    )
                  ),
                ) ,
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    widget.additional,
                    style: TextStyle(
                      fontSize: 12,
                    )
                  ),
                ) ,
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: pressAttention ? Icon(Icons.star_sharp) : Icon(Icons.star_border),
                        onPressed: () => {
                          pressAttention ? globalData.vocabularyRepo!.deleteFavouriteVocabulary(widget.id) : globalData.vocabularyRepo!.addVocabularyToFavorites(widget.id, widget.italian, widget.german, widget.additional),
                          setState(() => pressAttention = !pressAttention)
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.mic),
                        onPressed:() async {
                          VoiceSpeaker().speakItalianWord(widget.italian);
                        }
                      )
                    ]
                  ),
                ) ,             
              ),
            ],
          )
    );
  }
}

class VocabularyListTileWidget extends StatefulWidget {

  @override
  State<VocabularyListTileWidget> createState() => _VocabularyListTileWidgetState();

}
class _VocabularyListTileWidgetState extends State<VocabularyListTileWidget> {

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(0),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    'Italienisch',
                    style:TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ) ,
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    'Deutsch',
                    style:TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ) ,
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    'Zusätzliches',
                    style:TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ) ,
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Center(),            
              ),
            ],
          )
    );
  }
}

class ListWidget extends StatelessWidget {
  ListWidget(this.amountOfWords, this.level, this.title, this.id, {super.key});

  final int amountOfWords;
  final int level;
  final String title;
  final String id;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: _getTileColor(this.level),
      leading: Text('${this.amountOfWords.toString()} Wörter', textAlign: TextAlign.center,),
      title: 
        Padding(
          padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _getLevelIcon(this.level),
                        SizedBox(width: 4,),
                        _getLevelText(this.level)
                      ]
                  ),
                ),
                Expanded(
                  child: Text ('${this.title}', textAlign: TextAlign.center,),
                  flex: 10
                ),
              ],
            )
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getTrainingStartItem(this.level, context),
            SizedBox(width: 14),
            _getLockedUnlockedItem(this.level, context),
            SizedBox(width: 14), 
            IconButton(
              icon: Icon(Icons.search),
              tooltip: 'Vokabeln anschauen',
              onPressed:() {
                if (this.level <= globalData.user!.level){
                  context.pushNamed('vocabularies_details', pathParameters: {'tablename': this.title, 'table_id': this.id});
                  //context.goNamed('vocabularies_details', pathParameters: {'tablename': this.title, 'table_id': this.id}); 
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Level noch nicht freigeschalten!'))
                  );
                }
              }
            ),
            SizedBox(width: 14),
            IconButton(
              icon: Icon(Icons.download),
              tooltip: 'PDF generieren',
              onPressed:() {
                if (this.level <= globalData.user!.level){
                  _createPDF(this.title, this.id, this.level);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Level noch nicht freigeschalten!'))
                  );
                }
              }
            )
          ]
        ) 
      );
  }

  Future<void> _createPDF(String title, String id, int level) async {
    List<Vocabulary> vocabularies = VocabularyHandler().getAllVocabularies(id, title);

    PdfDocument document = PdfDocument();
    PdfPageTemplateElement header2 = PdfPageTemplateElement(
    Rect.fromLTWH(0, 0, document.pageSettings.size.width, 50));

    PdfCompositeField compositefields = PdfCompositeField(
        font: PdfStandardFont(PdfFontFamily.timesRoman, 19),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        text: '${title} (${level !=0 ? level : ''})');

    compositefields.draw(header2.graphics,
        Offset(220, 10 - PdfStandardFont(PdfFontFamily.timesRoman, 11).height));

    document.template.top = header2;

    PdfPageTemplateElement footer = PdfPageTemplateElement(
      Rect.fromLTWH(0, 0, document.pageSettings.size.width, 40));

    PdfPageNumberField pageNumber = PdfPageNumberField(
      font: PdfStandardFont(PdfFontFamily.timesRoman, 10),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)));

    pageNumber.numberStyle = PdfNumberStyle.numeric;

    PdfPageCountField count = PdfPageCountField(
    font: PdfStandardFont(PdfFontFamily.timesRoman, 10),
    brush: PdfSolidBrush(PdfColor(0, 0, 0)));

    count.numberStyle = PdfNumberStyle.numeric;

    PdfCompositeField compositeField = PdfCompositeField(
        font: PdfStandardFont(PdfFontFamily.timesRoman, 10),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        text: 'Seite {0} von {1}',
        fields: <PdfAutomaticField>[pageNumber, count]);
    compositeField.bounds = footer.bounds;

    compositeField.draw(footer.graphics,
      Offset(450, 20 - PdfStandardFont(PdfFontFamily.timesRoman, 19).height));

    document.template.bottom = footer;

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 3);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = "italienisch";
    header.cells[1].value = "deutsch";
    header.cells[2].value = "zusätzliches";

    header.style = PdfGridCellStyle(
      backgroundBrush: PdfBrushes.lightGray,
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(PdfFontFamily.timesRoman, 12),
    );

    for (final vocabulary in vocabularies) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = vocabulary.italian;
      row.cells[1].value = vocabulary.german;
      row.cells[2].value = vocabulary.additional;
    }

    grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 10, right: 3, top: 4, bottom: 4),
      backgroundBrush: PdfBrushes.white,
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(PdfFontFamily.timesRoman, 12),
    );

    grid.draw(
        page: document.pages.add(), bounds: const Rect.fromLTWH(0, 0, 0, 0));
    List<int> bytes = await document.save();

    AnchorElement(
        href:
            "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", "parlaItaliano_${title}_(${level}).pdf")
      ..click();

    document.dispose();
  }

  Icon _getLevelIcon(int vocabularyListLevel){
    if (vocabularyListLevel == 0){
      return Icon(Icons.star_sharp);
    } else {
      return Icon(Icons.emoji_events);
    }
  }

  Text _getLevelText(int vocabularyListLevel){
    if (vocabularyListLevel == 0){
      return Text("");
    } else {
      return Text('${vocabularyListLevel.toString()}', textAlign: TextAlign.start,);
    }
  }

  Color? _getTileColor(int vocabularyListLevel){
    if (vocabularyListLevel > globalData.user!.level){
      return Colors.grey[300];
    } else {
      return Colors.white;
    }
  }

  Widget _getTrainingStartItem(int vocabularyListLevel, BuildContext context) {
    if (vocabularyListLevel == globalData.user!.level + 1){
      return IconButton(
        icon: Icon(Icons.fitness_center),
        tooltip: 'Training starten',
        onPressed: (){
          routes.dialogBuilder(context);
        },
      );
    } else {
      return Visibility(
        maintainSize: true, 
        maintainAnimation: true,
        maintainState: true,
        visible: false, 
        child: IconButton(
          icon: Icon(Icons.fitness_center),
          tooltip: 'Training starten',
          onPressed: (){
            routes.dialogBuilder(context);
          },
        )
      );
    }
  }

  IconButton _getLockedUnlockedItem(int vocabularyListLevel, BuildContext context){
    if (vocabularyListLevel > globalData.user!.level){
      return IconButton(
        icon: Icon(Icons.lock),
        tooltip: 'noch nicht freigeschaltet',
        onPressed: (){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Level noch nicht freigeschalten!'))
          );
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.done_rounded),
        tooltip: 'freigeschaltet',
        onPressed: (){
        },
      );
    }
  }

  bool _checkIfTestCanStart(BuildContext context) {
    String lastTest = globalData.user!.lastTestDate;
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    return (lastTest != date.toString());
  }
}
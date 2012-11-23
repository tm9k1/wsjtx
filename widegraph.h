#ifndef WIDEGRAPH_H
#define WIDEGRAPH_H
#include <QDialog>

namespace Ui {
  class WideGraph;
}

class WideGraph : public QDialog
{
  Q_OBJECT

public:
  explicit WideGraph(QWidget *parent = 0);
  ~WideGraph();

  double m_dialFreq;

  void   dataSink2(float s[], float red[], float df3, int ihsym,
                   int ndiskdata, uchar lstrong[]);
  void   setQSOfreq(int n);
  int    QSOfreq();
  int    nSpan();
  int    nStartFreq();
  float  fSpan();
  void   saveSettings();
  int    Tol();
  void   setTol(int n);
  void   setFcal(int n);
  void   setPalette(QString palette);
  void   setFsample(int n);
  void   setPeriod(int ntrperiod, int nsps);
  void   setTxFreq(int n);
  double fGreen();

  qint32 m_qsoFreq;

signals:
  void freezeDecode2(int n);
  void f11f12(int n);

public slots:
  void wideFreezeDecode(int n);
  void initIQplus();

protected:
  virtual void keyPressEvent( QKeyEvent *e );

private slots:
  void on_waterfallAvgSpinBox_valueChanged(int arg1);
  void on_freqSpanSpinBox_valueChanged(int arg1);
  void on_zeroSpinBox_valueChanged(int arg1);
  void on_gainSpinBox_valueChanged(int arg1);
  void on_autoZeroPushButton_clicked();
  void on_fDialLineEdit_editingFinished();
  void on_rbCurrent_clicked();
  void on_rbCumulative_clicked();
  void on_rbJT9Sync_clicked();

private:
  qint32 m_waterfallAvg;
  qint32 m_fCal;
  qint32 m_fSample;
  qint32 m_TRperiod;
  qint32 m_nsps;
  qint32 m_ntr0;

  Ui::WideGraph *ui;
};

#ifdef WIN32
extern int set570(double freq_MHz);
#endif

#endif // WIDEGRAPH_H

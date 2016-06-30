unit uSCM_NoPPIDPacking;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uMotherForm, ADODB, DB, ExtCtrls, StdCtrls, MPlayer, Grids,inifiles,
  DBGrids;

type
  TfrmNoPPIDPacking = class(TfrmMotherForm)
    Panel1: TPanel;
    Label1: TLabel;
    PnlUser: TPanel;
    Panel4: TPanel;
    Panel7: TPanel;
    Label7: TLabel;
    PnlCustPN: TPanel;
    Panel8: TPanel;
    Label6: TLabel;
    PnlCust: TPanel;
    Label3: TLabel;
    PnlLine: TPanel;
    Panel2: TPanel;
    GroupBox4: TGroupBox;
    DBGrid1: TDBGrid;
    MediaPlayer1: TMediaPlayer;
    GroupBox3: TGroupBox;
    Panel5: TPanel;
    Panel10: TPanel;
    Label17: TLabel;
    Pnlcn: TPanel;
    Panel11: TPanel;
    Label16: TLabel;
    Pnlsn: TPanel;
    Panel12: TPanel;
    Label10: TLabel;
    lblWO_NUM: TLabel;
    pnlstdc: TPanel;
    Panel6: TPanel;
    PnlNowc: TPanel;
    pnlNowW_NUM: TPanel;
    pnlW: TPanel;
    pnlSTDW_NUM: TPanel;
    Panel3: TPanel;
    Label12: TLabel;
    edtdata: TEdit;
    DataSource1: TDataSource;
    ADOQuery2: TADOQuery;
    Label5: TLabel;
    PnlModelName: TPanel;
    Label2: TLabel;
    PnlMo: TPanel;
    Label4: TLabel;
    pnlrev: TPanel;
    Label15: TLabel;
    pnlmserial: TPanel;
    adosprcCheckR: TADOStoredProc;
    ADOQuery3: TADOQuery;
    procedure edtdataKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ShowMsg(MsgShow:String;C_Color:TColor);

    procedure pCheckEmp(sEmpId:string);
    procedure pCheckMo(sMoNumber:string);
    procedure pCheckCarNo(sCarNo:string);
    procedure pGetMoRealQty(mo:string);
    procedure pGetCartonRealQty(Carton:string);
    procedure pRefresh(sCarNo:string);
    { Public declarations }
  end;

var
  frmNoPPIDPacking: TfrmNoPPIDPacking;
  fStep,iCustStart,iCustLen:integer;        // 1=inputemp,2=inputmo,3=inputcarton,
  sEmpNo,shop,path,sn:string;
  Serial_number:array of string;

implementation

uses uFrmMain;

{$R *.dfm}

procedure TfrmNoPPIDPacking.edtdataKeyPress(Sender: TObject;
  var Key: Char);
begin
  inherited;
    if key=#13 then
    begin
        if edtdata.Text<>'UNDO' then
        case fStep of
            1 : pCheckEmp(EdtData.Text);
            2 : pCheckMO(EdtData.Text);
            3 : pCheckCarNo(EdtData.Text);
        end
        else
        begin
            self.PnlUser.Caption:='';
            self.PnlLine.Caption:='';
            self.PnlMo.Caption:='';
            self.pnlmserial.Caption:='';
            self.pnlModelName.Caption:='';
            self.pnlrev.Caption:='';
            self.PnlCustPN.Caption:='';
            self.PnlCust.Caption:='';
            fStep:=1;
            adoqrydata.Close;
            showmsg('�п�J�A���u��',clgreen);
        end;
    end;
end;

procedure TfrmNoPPIDPacking.pCheckCarNo(sCarNo: string);
var
  i,l_start,l_end,l_len,i_cartonlen:integer;
  str,l_word,l_str:string;
begin
  if strtoint(self.pnlNowW_NUM.Caption)>=strtoint(self.pnlSTDW_NUM.Caption) then
  begin
    ShowMsg('�u�O�w�g�]�˧���',clRed);
    exit;
  end;

  for i:=1 to Length(sCarNo) do
  begin
    Str:=copy(EdtData.Text,i,1);
    if not( ((str>='A') and (str<='Z')) or ( (str>='0') and (str<='9')) or  (str='-') ) then
    begin
        ShowMsg('�A��J���c�����X��'+IntToStr(i)+'��s�b�ýX:'+str+',�Э��s��J',clRed);
        exit;
    end;
  end;

    {if copy(sCarNo,iCustStart,iCustlen) <> PnlModelName.Caption then
    begin
        ShowMsg('�c���Ƹ����~�M���ˬd�c�����X',clRed);
        exit;
    end;}

    with adoqrytemp do
    begin
      close;
      sql.Text := 'select * from sfis1.C_BC_CHECK_RULE_T where bc_type=''CTN'' AND'+
                  ' model_name='''+self.PnlModelName.Caption+''' and rev='''+self.pnlrev.Caption+'''';
      open;
    end;
    IF adoqrytemp.recordcount<1 then
    begin
      l_str:='�c�����X�W�h�S���@';
      ShowMsg(l_str,CLRED);
      Abort;
    end;

    l_start:=adoqrytemp.fieldbyname('key_start').AsInteger;
    l_end :=adoqrytemp.fieldbyname('key_end').AsInteger;
    l_len :=adoqrytemp.fieldbyname('length').AsInteger;
    l_word:=adoqrytemp.fieldbyname('key_word').AsString;
    i_cartonlen:=adoqrytemp.FieldByName('length').AsInteger;
    if adoqrytemp.FieldByName('check_flag').AsInteger=1   then
    begin
      IF LENGTH (sCarNo) <> adoqrytemp.FieldByName('length').AsInteger then
      begin
        l_str:= '�c�����X�W�h���פ���('+adoqrytemp.FieldByName('length').AsString+')';
        ShowMsg(l_str,CLRED);
        Abort;
      end;
    end;
    if adoqrytemp.FieldByName('check_flag').AsInteger=2 then
    begin
      IF LENGTH (sCarNo) <> adoqrytemp.FieldByName('length').AsInteger then
      begin
        l_str:= '�c�����X�W�h���פ���('+adoqrytemp.FieldByName('length').AsString+')';
        ShowMsg(l_str,CLRED);
        Abort;
      end;
      if copy(sCarNo,l_start,l_end-l_start+1)<>l_word then
      begin
        l_str:='�c�����X����r����'+l_word;
        showMsg(l_str,clred);
        abort;
      end;
    end;

    //-------------�ˬd�O�_�Q��
    with adoqrytemp do
    begin
      close;
      sql.Text:='select carton_no from sfism4.r_wip_tracking_t where carton_no=:car';
      parameters.ParamByName('car').Value:=sCarNo;
      open;
      if recordcount>=1 then
      begin
          showMsg('�ӽc���w�g�]��,�п�J�s�c��',clRed);
          close;
          exit;
      end;
      close;
    end;

    frmMain.DBConnection.BeginTrans;

    try
        //------CARTON_LIST���trigger���J
        {adoquery2.Close;
        adoquery2.SQL.Text:='INSERT INTO SFISM4.R_CARTON_LIST_T (CARTON_NO,MODEL_NAME,'+
            ' REV,CARTON_QTY,PACKED_DATE,EMP_NO,STATUS,LINE_NAME) VALUES '+
            ' (:CAR,:MODEL,:REV,:QTY,SYSDATE,:EMP,''1'',:LINE)';}

        if (strtoint(pnlSTDW_NUM.Caption) - strtoint(pnlNowW_NUM.Caption)) >= strtoint(pnlstdc.Caption) then
        begin
            setlength(serial_number,strtoint(self.pnlstdc.Caption));
            with self.ADOQuery2 do
            begin
              close;
              sql.Text:='SELECT * FROM SFISM4.R_WIP_TRACKING_T WHERE CARTON_NO=''N/A'' AND  MO_NUMBER='''+PnlMo.Caption+''' ORDER BY SERIAL_NUMBER ';
              open;
              for i:=1 to strtoint(self.pnlstdc.Caption) do
              begin
                 serial_number[i-1]:=self.ADOQuery2.fieldbyname('SERIAL_NUMBER').AsString;
                 self.ADOQuery2.Next;
              end;
            end;
            for i:=1 to strtoint(pnlstdc.Caption) do
            begin
                AdoQryTemp.close;
                AdoQryTemp.SQL.Text:='UPDATE SFISM4.R_WIP_TRACKING_T SET SECTION_NAME=''PACKING'',GROUP_NAME=''PACKING'', '+
                                     'STATION_NAME=''PACKING'',CARTON_NO='''+sCarNo+''',EMP_NO='''+sEmpNo+''' WHERE '+
                                     'SERIAL_NUMBER='''+serial_number[i-1]+''' ';
                AdoQryTemp.execsql;

                with adosprcCheckR do   // ��ssfism4.r_station_rec_t
                begin
                    Close;
                    Parameters.Clear;            //�M���Ҧ����Ѽ�
                    ProcedureName:='STN_REC_Z';
                    Parameters.CreateParameter('P1',ftString,pdInput,4000,Unassigned);
                    Parameters.CreateParameter('P2',ftString,pdInput,4000,Unassigned);
                    Parameters.CreateParameter('P3',ftString,pdInput,4000,Unassigned);
                    Parameters.CreateParameter('P4',ftString,pdInput,4000,unassigned);
                    Parameters.CreateParameter('P5',ftString,pdInput,4000,unassigned);
                    Parameters.CreateParameter('P6',ftString,pdInput,4000,unassigned);
                    Parameters.CreateParameter('P7',ftString,pdInput,4000,unassigned);
                    Parameters.CreateParameter('P8',ftString,pdInput,4000,unassigned);
                    Parameters.CreateParameter('P9',ftString,pdInput,4000,unassigned);
                    Parameters.Items[0].Value:=self.pnlline.Caption;
                    Parameters.Items[1].Value:='PACKING';
                    Parameters.Items[2].Value:='PACKING';
                    Parameters.Items[3].Value:='PACKING';
                    Parameters.Items[4].Value:='Shop';
                    Parameters.Items[5].Value:=self.pnlMO.Caption;
                    Parameters.Items[6].Value:=serial_number[i-1];
                    Parameters.Items[7].Value:= 'N/A';
                    Parameters.Items[8].Value:=0;
                    ExecProc;
                end;


                self.PnlNowc.Caption:=inttostr(i);
                self.PnlNowc.Refresh;
            end;

            {adoquery2.Parameters.ParamByName('car').Value:=  sCarNo ;
            adoquery2.Parameters.ParamByName('model').Value:= PnlModelName.Caption ;
            adoquery2.Parameters.ParamByName('rev').Value:=  pnlrev.Caption ;
            adoquery2.Parameters.ParamByName('qty').Value:= strtoint(pnlstdc.Caption) ;
            adoquery2.Parameters.ParamByName('emp').Value:= sEmpNo ;
            adoquery2.Parameters.ParamByName('line').Value:= PnlLine.Caption ;
            //adoquery2.Parameters.ParamByName('mo').Value:= self.PnlMo.Caption;
            adoquery2.ExecSQL;}

        end
        else
        begin
            setlength(serial_number,strtoint(pnlSTDW_NUM.Caption) - strtoint(pnlNowW_NUM.Caption));
            with self.ADOQuery2 do
            begin
              close;
              sql.Text:='SELECT * FROM SFISM4.R_WIP_TRACKING_T WHERE CARTON_NO=''N/A'' AND  MO_NUMBER='''+PnlMo.Caption+''' ';
              open;
              for i:=1 to strtoint(pnlSTDW_NUM.Caption) - strtoint(pnlNowW_NUM.Caption) do
              begin
                 serial_number[i-1]:=self.ADOQuery2.fieldbyname('SERIAL_NUMBER').AsString;
                 self.ADOQuery2.Next;
              end;
            end;
            for i:=1 to (strtoint(pnlSTDW_NUM.Caption) - strtoint(pnlNowW_NUM.Caption)) do
            begin
                AdoQryTemp.close;
                AdoQryTemp.SQL.Text:='UPDATE SFISM4.R_WIP_TRACKING_T SET SECTION_NAME=''PACKING'',GROUP_NAME=''PACKING'', '+
                                     'STATION_NAME=''PACKING'',CARTON_NO='''+sCarNo+''',EMP_NO='''+sEmpNo+''' WHERE '+
                                     'SERIAL_NUMBER='''+serial_number[i-1]+''' ';
                AdoQryTemp.execsql;

                with adosprcCheckR do   // ��ssfism4.r_station_rec_t
                begin
                    Close;
                    Parameters.Clear;            //�M���Ҧ����Ѽ�
                    ProcedureName:='STN_REC_Z';
                    Parameters.CreateParameter('P1',ftString,pdInput,4000,Unassigned);
                    Parameters.CreateParameter('P2',ftString,pdInput,4000,Unassigned);
                    Parameters.CreateParameter('P3',ftString,pdInput,4000,Unassigned);
                    Parameters.CreateParameter('P4',ftString,pdInput,4000,unassigned);
                    Parameters.CreateParameter('P5',ftString,pdInput,4000,unassigned);
                    Parameters.CreateParameter('P6',ftString,pdInput,4000,unassigned);
                    Parameters.CreateParameter('P7',ftString,pdInput,4000,unassigned);
                    Parameters.CreateParameter('P8',ftString,pdInput,4000,unassigned);
                    Parameters.CreateParameter('P9',ftString,pdInput,4000,unassigned);
                    Parameters.Items[0].Value:=self.pnlline.Caption;
                    Parameters.Items[1].Value:='PACKING';
                    Parameters.Items[2].Value:='PACKING';
                    Parameters.Items[3].Value:='PACKING';
                    Parameters.Items[4].Value:='Shop';
                    Parameters.Items[5].Value:=self.pnlMO.Caption;
                    Parameters.Items[6].Value:=serial_number[i-1];
                    Parameters.Items[7].Value:= 'N/A';
                    Parameters.Items[8].Value:=0;
                    ExecProc;
                end;

                self.PnlNowc.Caption:=inttostr(i);
                self.PnlNowc.Refresh;
            end;

            {adoquery2.Parameters.ParamByName('car').Value:=  sCarNo ;
            adoquery2.Parameters.ParamByName('model').Value:= PnlModelName.Caption ;
            adoquery2.Parameters.ParamByName('rev').Value:=  pnlrev.Caption ;
            adoquery2.Parameters.ParamByName('qty').Value:= strtoint(pnlstdc.Caption) ;
            adoquery2.Parameters.ParamByName('emp').Value:= sEmpNo ;
            adoquery2.Parameters.ParamByName('line').Value:= PnlLine.Caption ;
            //adoquery2.Parameters.ParamByName('mo').Value:= self.PnlMo.Caption;
            adoquery2.ExecSQL;}
        end;



    except
        frmMain.DBConnection.RollbackTrans;
        showMsg('�c����ƫO�s����,�Э���',clRed);
    end;

    frmMain.DBConnection.CommitTrans;


    pGetMoRealQty(self.PnlMo.Caption);

    if strtoint(pnlSTDW_NUM.Caption) <= strtoint(pnlNowW_NUM.Caption) then
    begin
        showMsg('�Ӥu�O�w�g�F��ؼмƶq,�п�J��L�u�O',clYellow);
        fStep:=2;
        exit;
    end;



    //  �ˬd�O�_�˺� 
    pGetCartonRealQty(sCarNo);
    Pnlcn.Caption:=EdtData.Text;
    if strtoint(self.pnlNowW_NUM.Caption) >= strtoint(self.pnlSTDW_NUM.Caption) then
    begin
        ShowMsg('�ӽc�w�g�˺�,�б��J�s�c��',clred);
        exit;
    end
    else
    begin
        fStep:=3;   // ��Ʊ��y��y���X
        pRefresh(sCarNo);
        ShowMsg('�c����J���\,�б��J�s�c��',clGreen);
        exit;
    end;
end;

procedure TfrmNoPPIDPacking.pCheckEmp(sEmpId: string);
begin
  with adoqrytemp do
  begin
      close;
      sql.Text:='select * from sfis1.c_emp_desc_t where emp_no=:emp';
      parameters.ParamByName('emp').Value:=sEmpId;
      open;
      if recordcount>0 then
      begin
          pnluser.Caption:=fieldbyname('emp_name').AsString;
          fStep:=2;
          sEmpNo:=sEmpId;
          ShowMsg('�u�����T,�п�J�u�O',clGreen);

      end
      else
          ShowMsg('�A��J�����u�����s�b,�Э��s��J',clRed);
  end;
end;

procedure TfrmNoPPIDPacking.pCheckMo(sMoNumber: string);
var
  PackingBy:string;
begin
    with AdoQryTemp do
    begin
        close;
        sql.Text:='SELECT * FROM SFISM4.R_MO_BASE_T WHERE MO_NUMBER=:MO';
        parameters.ParamByName('MO').Value:=sMoNumber;
        open;
        if recordcount>0 then
        begin
            adoquery2.Close;
            adoquery2.SQL.Text:='SELECT * FROM SFIS1.C_MODEL_DESC_T WHERE '+
                ' MODEL_NAME=:MODELNAME AND REV=:VER ';
            adoquery2.Parameters.ParamByName('MODELNAME').Value:=fieldbyname('MODEL_NAME').AsString;
            adoquery2.Parameters.ParamByName('VER').Value:=fieldbyname('REV').AsString;
            adoquery2.Open;
            if adoquery2.RecordCount<1 then
            begin
                ShowMsg('�䤣��Ӥu�O����������!',clred);
                exit;
            end
            else
            begin
                PackingBy:=self.ADOQuery2.fieldbyname('PACK_BY_PPID').AsString;
                if PackingBy='Y' then
                begin
                  self.ShowNGMsg('���u�O���Ƹ��O��PPID�]��,����Φ��{���]��,�п�J��L�u�O');
                  //fStep:=2;
                  abort;
                end;
                pnlMO.Caption:=sMoNumber;
                pnlmserial.Caption:=adoquery2.FieldByName('MODEL_SERIAL').AsString;
                pnlmodelname.Caption:=adoquery2.FieldByName('Model_name').AsString;
                pnlrev.Caption:=adoquery2.FieldByName('rev').AsString;
                //PnlCustPN.Caption:=adoquery2.FieldByName('HH_NO').AsString;
                pnlcust.Caption:=adoquery2.FieldByName('cust_no').AsString;

                pnlstdc.Caption:= adoquery2.FieldByName('STD_CARTON_QTY').AsString;
                PnlNowc.Caption:='0';
                self.pnlNowW_NUM.Caption:=adoqrytemp.fieldbyname('output_qty').AsString;
                pnlSTDW_NUM.Caption:=adoqrytemp.FieldByName('target_QTY').AsString;
            end;
            adoquery2.Close;
        end
        else
        begin
            ShowMsg('�䤣��Ӥu�O!',clred);
            exit;
        end;
        close;
    end;

    pGetMoRealQty(sMoNumber);

    // �P�_�u�O�O�_�w�g�F��ؼмƶq 
    if strtoint(self.pnlNowW_NUM.Caption) >= strtoint(self.pnlSTDW_NUM.Caption) then
    begin
        showmsg('�w�g�F��u�O�ؼмƶq�M�п�ܨ䥦�u�O',clred);
    end
    else
    begin
        ShowMsg('�u�O���T,�п�J�c��',clGreen);
        fStep:=3
//pl-----------------------------------------------------------
 //       MediaPlayer4.Open;
 //       MediaPlayer4.Play;
//pl-------------------------------------------------------------
    end;
end;

procedure TfrmNoPPIDPacking.pGetMoRealQty(mo: string);
begin
    with adoqrytemp do
    begin
        close;
        sql.Text:='SELECT COUNT(SERIAL_NUMBER) OUTPUT_QTY FROM SFISM4.R_WIP_TRACKING_T '+
            ' WHERE MO_NUMBER='''+mo+''' AND GROUP_NAME IN(''PACKING'',''SHIPPING'') '+
            ' AND NEXT_GROUP<>''PACKING'' ';
        open;
        //SHOWMESSAGE(fieldbyname('OUTPUT_QTY').AsString);
        self.pnlNowW_NUM.Caption:=fieldbyname('OUTPUT_QTY').AsString;
    end;
end;

procedure TfrmNoPPIDPacking.ShowMsg(MsgShow: String; C_Color: TColor);
begin
   pnlMsg.Caption:=MsgShow;
   pnlMsg.Color:=C_Color;
   EdtData.SelectAll;
   EdtData.SetFocus;
   pnlMsg.Update;
end;

procedure TfrmNoPPIDPacking.FormShow(Sender: TObject);
var
  myinifile :Tinifile;
begin
  inherited;
  adosprcCheckR.Connection :=frmMain.DBConnection;
  GetDir(0,PATH);
  myinifile:=TInifile.Create(PATH+'\CONFIG.INI');
  try
   Pnlline.Caption :=myinifile.ReadString('PACKING','LINE_NAME','');
   //BACKBY:=myinifile.ReadString('PACKING','PACK_BY','');
   //IF BACKBY ='1' THEN
     //PACKBY.Caption :='MO'
   //ELSE
     //PACKBY.CAPTION :='MODEL';
   //BACKBY:=myinifile.ReadString('PACKING','PACK_BY','');
   //Temp_Carton :=myinifile.ReadString('PACKING','CURRENT_CARTON','');
   //Temp_Pallet :=myinifile.ReadString('PACKING','CURRENT_pallet','');
   //Line_Check_Flag:=myinifile.ReadString('PACKING','LINE_CHECK','');
   shop:=myinifile.ReadString('PACKING','SHOP_NO','');
   iCustStart:=myinifile.ReadInteger('PACKING','startpos',0);
   iCustLen:=myinifile.ReadInteger('PACKING','length',0);

  finally
      myinifile.Free ;
  end;
  SELF.edtdata.SetFocus;
  if Pnlline.caption='' then
  begin
    showmessage('    ^_^ �ܩ�p,�]�˽u�S���]�m!');               // �]�˽u�]�m
    application.Terminate;
  end;

   showmsg('�п�J�A���u��',clgreen);
   fStep:=1;  // ��Ʊ��y�u��
end;

procedure TfrmNoPPIDPacking.pRefresh(sCarNo:string);
begin
   with self.adoqrydata do   
   begin
     close;
     sql.Text:='select rownum, serial_number from sfism4.r_wip_tracking_t '+
         ' where carton_no=:carno ';
     parameters.ParamByName('carno').Value:=sCarNo;
     open;
     last;
   end;
   self.DataSource1.DataSet:=adoqrydata;
   dbgrid1.Columns[0].Title.caption:='�Ǹ�';
   dbgrid1.Columns[1].Title.caption:='��y';
   dbgrid1.Columns[0].Width:=50;
end;

procedure TfrmNoPPIDPacking.pGetCartonRealQty(Carton: string);
begin
  with self.AdoQryTemp do
  begin
      close;
      sql.Text:='select  carton_qty from sfism4.r_carton_list_t '+
          ' where carton_no=:car';

      parameters.ParamByName('car').Value:=carton;
      open;
      if recordcount>0 then
          self.PnlNowc.Caption:=fieldbyname('carton_qty').AsString
      else
          self.PnlNowc.Caption:='0';
      close;
  end;
end;

procedure TfrmNoPPIDPacking.FormResize(Sender: TObject);
begin
  inherited;
   panel1.Width:=self.Panel2.Width div 4 ;
    panel4.Width:=self.Panel2.Width div 4 ;
    panel7.Width:=self.Panel2.Width div 4 ;
    panel8.Width:=self.Panel2.Width div 4 ;
    self.PNLUSER.Width:= panel1.Width - 80;
    self.PnlLine.Width:= panel7.Width - 80;
    self.PnlMo.Width:= panel1.Width - 80;
    self.pnlmserial.Width:= panel4.Width - 80;
    self.PnlModelName.Width:= panel8.Width - 80;
    self.Pnlrev.Width:= panel4.Width - 80;
    self.PnlCustPN.Width:= panel7.Width - 80;
    self.pnlCust.Width:= panel8.Width - 80;
    SELF.edtdata.Width:=panel3.Width-120;
    self.DBGrid1.Columns[0].Width:=dbgrid1.Width div 6;
    self.DBGrid1.Columns[1].Width:= self.DBGrid1.Width -dbgrid1.Width div 4;
end;

end.

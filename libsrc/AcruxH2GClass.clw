OMIT('***')a
 * User: Carlos Pizzi
 * carlos.pizzi@gmail.com
 * Date: 28/11/2018
 * Uso los template de 
 * https://github.com/mikeduglas/cJSON
 * https://github.com/mikeduglas/libcurl
 ***
                        
                                  Member()
                                    PRAGMA('link(libcurl.lib)')
                                  Map
                                  End
    INCLUDE('AcruxH2GClass.equ'),ONCE                         
    INCLUDE('AcruxH2GClass.inc'),ONCE
    INCLUDE('LIBCURL.INC'),ONCE
    INCLUDE('cjson.inc'),ONCE  

!
curl                    TCurlClass
L:Res                   CURLcode, AUTO
L:RespBuffer            DynStr
L:RespBufferStr         STRING(2048)                          
L:ErrorRespBufferStr    STRING(2048)                          
L:sJson                 STRING(2048)                           
L:sUrl                  STRING(200)                            
L:bGetServerResponse    BYTE 

root                    &cJSON
jsonFactory             cJSONFactory


  
               
!---------------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.Construct    Procedure()
  CODE
!  SELF.Q &= NEW qtIDDescr
!  RETURN


!---------------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.Destruct    Procedure()
  CODE
!  IF NOT(SELF.Q &= NULL)
!     SELF.QFree()
!     DISPOSE(SELF.Q)
!  END
!  RETURN



!---------------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.Init    Procedure()
  CODE
!    SELF.InDebug = FALSE
  RETURN


!---------------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.Kill    Procedure()
  CODE
  RETURN


!---------------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.ConsultarUltimoError   Procedure()

parser                          cJSONFactory

GCUE                            GROUP
ConsultarUltimoError              GROUP
Secuencia                           LONG
Estado                              GROUP
QImpresora                             &QUEUE,NAME('Impresora')
QFiscal                                &QUEUE,Name('Fiscal')
                                    END
UltimoError                         STRING(50)
NumeroParametro                     LONG
Descripcion                         STRING(100)
Contexto                            STRING(100)
NombreParametro                     STRING(50)
                                  END
                                END
QImpresora                       QUEUE
Str                               STRING(100)
                                END
QFiscal                          QUEUE
Str                               STRING(100)
                                END

sFiscal         String(1024)
sImpresora      String(1024)
  Code

    GCUE.ConsultarUltimoError.Estado.QImpresora &= QImpresora
    GCUE.ConsultarUltimoError.Estado.QFiscal    &= QFiscal
    Clear(L:RespBufferStr)

    L:sJson='{{ ' & |
            '"ConsultarUltimoError": {{ } ' & |
            '}'
    

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    X#=self.SendRequest('ConsultarUltimoError')

    IF NOT parser.ToGroup(L:ErrorRespBufferStr, GCUE, FALSE, '[{{"name":"Impresora", "instance":'& INSTANCE(QImpresora, THREAD()) &'},'& |
                                '{{"name":"Fiscal", "instance":'& INSTANCE(QFiscal, THREAD()) &'}]')
      MESSAGE(parser.GetError())
      Return True
    END

    If Upper(GCUE.ConsultarUltimoError.UltimoError)<>'NO_CURRENT_ERROR'

       Clear(sFiscal)
       Loop X#=1 To Records(QFiscal)
            Get(QFiscal,X#)
            sFiscal = Clip(Left(sFiscal)) & Clip(Left(QFiscal.Str)) & Choose(X#<Records(QFiscal),',','')
       End
       Clear(sImpresora)
       Loop X#=1 To Records(QImpresora)
            Get(QImpresora,X#)
            sImpresora = Clip(Left(sImpresora)) & Clip(Left(QImpresora.Str)) & Choose(X#<Records(QImpresora),',','')
       End

       Message('Error: ' & Clip(Left(GCUE.ConsultarUltimoError.UltimoError)) &'|'& |
               'NumeroParametro: ' & GCUE.ConsultarUltimoError.NumeroParametro &'|'& |  
               'Descripción: ' & Clip(Left(GCUE.ConsultarUltimoError.Descripcion)) &'|'& |  
               'Contexto: ' & Clip(Left(GCUE.ConsultarUltimoError.Contexto)) &'|'& |  
               'Nombre Parámetro: ' & Clip(Left(GCUE.ConsultarUltimoError.NombreParametro)) &'|'& | 
               'Estado Fiscal: ' & Clip(Left(sFiscal)) &'|'& | 
               'Estado Impresora: ' & Clip(Left(sImpresora)))
!       Message(Clip(Left(L:RespBufferStr)))
       Return True

    End


    Return False
!---------------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.ConsultarEstado   Procedure(pCodigoComprobante)

parser                          cJSONFactory

GCE                             GROUP
ConsultarEstado                   GROUP
Secuencia                           STRING(20)
Estado                              GROUP
QImpresora                             &QUEUE,NAME('Impresora')
QFiscal                                &QUEUE,Name('Fiscal')
                                    END
EstadoAuxiliar                      GROUP
QEstadoAuxiliar                        &QUEUE,NAME('EstadoAuxiliar')
                                    END
EstadoInterno                       STRING(20) 
ComprobanteEnCurso                  STRING(20) 
CodigoComprobante                   STRING(20) 
NumeroUltimoComprobante             LONG
CantidadEmitidos                    LONG
CantidadCancelados                  LONG
                                  END
                                END
QImpresora                       QUEUE
Str                               STRING(30)
                                END
QFiscal                          QUEUE
Str                               STRING(30)
                                END
QEstadoAuxiliar                  QUEUE
Str                               STRING(30)
                                END


!sFiscal         String(1024)
!sImpresora      String(1024)
!sEstadoAuxiliar String(1024)

  Code

    Clear(GCE)
    Clear(QImpresora)
    Free(QImpresora)
    Clear(QFiscal)
    Free(QFiscal)
    Clear(QEstadoAuxiliar)
    Free(QEstadoAuxiliar)

    GCE.ConsultarEstado.Estado.QImpresora              &= QImpresora
    GCE.ConsultarEstado.Estado.QFiscal                 &= QFiscal
    GCE.ConsultarEstado.EstadoAuxiliar.QEstadoAuxiliar &= QEstadoAuxiliar

    L:sJson='{{ ' & |
        '"ConsultarEstado": ' & |
        '{{ ' & |
        '"CodigoComprobante" : "'&Clip(Left(pCodigoComprobante))&'", ' & |
        '} ' & |
        '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    X#=self.SendRequest('ConsultarEstado')

    IF NOT parser.ToGroup(L:RespBufferStr, GCE, FALSE, '[{{"name":"Impresora", "instance":'& INSTANCE(QImpresora, THREAD()) &'},'& |
                                '{{"name":"Fiscal", "instance":'& INSTANCE(QFiscal, THREAD()) &'},'& |
                                '{{"name":"EstadoAuxiliar", "instance":'& INSTANCE(QEstadoAuxiliar, THREAD()) &'}]')
      RETURN parser.GetError()
    END
    
    Return L:RespBufferStr

!---------------------------------------------------------------------------------------------------------------------------------------------------!

AH2G.ConsultarEstadoII   Procedure(String pCodigoComprobante, *AH2G:GSalida pGSalida)

parser                          cJSONFactory

GCE                             GROUP
ConsultarEstado                   GROUP
Secuencia                           STRING(20)
Estado                              GROUP
QImpresora                             &QUEUE,NAME('Impresora')
QFiscal                                &QUEUE,Name('Fiscal')
                                    END
EstadoAuxiliar                      GROUP
QEstadoAuxiliar                        &QUEUE,NAME('EstadoAuxiliar')
                                    END
EstadoInterno                       STRING(20) 
ComprobanteEnCurso                  STRING(20) 
CodigoComprobante                   STRING(20) 
NumeroUltimoComprobante             LONG
CantidadEmitidos                    LONG
CantidadCancelados                  LONG
                                  END
                                END
QImpresora                       QUEUE
Str                               STRING(30)
                                END
QFiscal                          QUEUE
Str                               STRING(30)
                                END
QEstadoAuxiliar                  QUEUE
Str                               STRING(30)
                                END


  Code

    Clear(GCE)
    Clear(QImpresora)
    Free(QImpresora)
    Clear(QFiscal)
    Free(QFiscal)
    Clear(QEstadoAuxiliar)
    Free(QEstadoAuxiliar)

    GCE.ConsultarEstado.Estado.QImpresora              &= QImpresora
    GCE.ConsultarEstado.Estado.QFiscal                 &= QFiscal
    GCE.ConsultarEstado.EstadoAuxiliar.QEstadoAuxiliar &= QEstadoAuxiliar

    L:sJson='{{ ' & |
        '"ConsultarEstado": ' & |
        '{{ ' & |
        '"CodigoComprobante" : "'&Clip(Left(pCodigoComprobante))&'", ' & |
        '} ' & |
        '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    X#=self.SendRequest('ConsultarEstado')

    IF NOT parser.ToGroup(L:RespBufferStr, GCE, FALSE, '[{{"name":"Impresora", "instance":'& INSTANCE(QImpresora, THREAD()) &'},'& |
                                '{{"name":"Fiscal", "instance":'& INSTANCE(QFiscal, THREAD()) &'},'& |
                                '{{"name":"EstadoAuxiliar", "instance":'& INSTANCE(QEstadoAuxiliar, THREAD()) &'}]')
!      MESSAGE(parser.GetError())
!      RETURN parser.GetError()
    END
    
    

    Clear(pGSalida.Fiscal)
    Loop X#=1 To Records(QFiscal)
         Get(QFiscal,X#)
         pGSalida.Fiscal = Clip(Left(pGSalida.Fiscal)) & Clip(Left(QFiscal.Str)) & Choose(X#<Records(QFiscal),',','')
    End

    Clear(pGSalida.Impresora)
    Loop X#=1 To Records(QImpresora)
         Get(QImpresora,X#)
         pGSalida.Impresora = Clip(Left(pGSalida.Impresora)) & Clip(Left(QImpresora.Str)) & Choose(X#<Records(QImpresora),',','')
    End

    Clear(pGSalida.EstadoAuxiliar)
    Loop X#=1 To Records(QEstadoAuxiliar)
         Get(QEstadoAuxiliar,X#)
         pGSalida.EstadoAuxiliar = Clip(Left(pGSalida.EstadoAuxiliar)) & Clip(Left(QEstadoAuxiliar.Str)) & Choose(X#<Records(QEstadoAuxiliar),',','')
    End
    
    pGSalida.EstadoInterno = GCE.ConsultarEstado.EstadoInterno
    pGSalida.ComprobanteEnCurso = GCE.ConsultarEstado.ComprobanteEnCurso
    pGSalida.NumeroUltimoComprobante = GCE.ConsultarEstado.NumeroUltimoComprobante
    pGSalida.CantidadEmitidos = GCE.ConsultarEstado.CantidadEmitidos
    pGSalida.CantidadCancelados = GCE.ConsultarEstado.CantidadCancelados
    
    Return

!---------------------------------------------------------------------------------------------------------------------------------------------------!





AH2G.CierreX        Procedure()
parser                          cJSONFactory
L:HayError Byte

OuterGroup                      GROUP
CerrarJornadaFiscal               GROUP
Secuencia                           STRING(20)
Estado                              GROUP
Impresora                             &QUEUE
Fiscal                                &QUEUE
                                    END
Reporte                                 STRING(8)
Numero                                  LONG
FechaInicio                             STRING(6)
HoraInicio                              STRING(6)
FechaCierre                             STRING(6)
HoraCierre                              STRING(6)
DF_Total                                REAL
DF_TotalIVA                             REAL
DF_TotalTributos                        REAL
DF_CantidadCancelados                   LONG
NC_Total                                REAL
NC_TotalIVA                             REAL
NC_TotalTributos                        REAL
NC_CantidadEmitidos                     LONG
DNFH_CantidadEmitidos                   LONG
                                  END
                                END

Impresora                       QUEUE
Str                               STRING(20)
                                END

Fiscal                          QUEUE
Str                               STRING(20)
                                END

  Code

    OuterGroup.CerrarJornadaFiscal.Estado.Impresora &= Impresora
    OuterGroup.CerrarJornadaFiscal.Estado.Fiscal    &= Fiscal

    L:sJson='{{ ' & |
            '"CerrarJornadaFiscal": ' & |
            '{{ ' & |
            '"Reporte" : "ReporteX" ' & |
            '} ' & |
            '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('CerrarJornadaFiscalX')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Cerrar Jornada Fiscal X') 
       End 
    End
    Return L:HayError



!---------------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.CierreZ        Procedure()
L:HayError  Byte
parser                          cJSONFactory

OuterGroup                      GROUP
CerrarJornadaFiscal               GROUP
Secuencia                           STRING(20)
Estado                              GROUP
Impresora                             &QUEUE
Fiscal                                &QUEUE
                                    END
Reporte                                 STRING(8)
Numero                                  LONG
Fecha                                   STRING(6)
DF_Total                                REAL
DF_TotalGravado                         REAL
DF_TotalNoGravado                       REAL
DF_TotalExento                          REAL
DF_TotalIVA                             REAL
DF_TotalTributos                        REAL
DF_CantidadEmitidos                     LONG
DF_CantidadCancelados                   LONG
NC_Total                                REAL
NC_TotalGravado                         REAL
NC_TotalNoGravado                       REAL
NC_TotalExento                          REAL
NC_TotalIVA                             REAL
NC_TotalTributos                        REAL
NC_CantidadEmitidos                     LONG
NC_CantidadCancelados                   LONG
DNFH_Total                              REAL
DNFH_CantidadEmitidos                   LONG
                                  END
                                END

Impresora                       QUEUE
Str                               STRING(20)
                                END

Fiscal                          QUEUE
Str                               STRING(20)
                                END

  Code

    OuterGroup.CerrarJornadaFiscal.Estado.Impresora &= Impresora
    OuterGroup.CerrarJornadaFiscal.Estado.Fiscal    &= Fiscal

    L:sJson='{{ ' & |
            '"CerrarJornadaFiscal": ' & |
            '{{ ' & |
            '"Reporte" : "ReporteZ" ' & |
            '} ' & |
            '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('CerrarJornadaFiscalZ')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Cerrar Jornada Fiscal Z') 
       End 
    End
    Return L:HayError

!    IF NOT parser.ToGroup(L:RespBufferStr, OuterGroup, FALSE, '[{{"name":"Impresora", "instance":'& INSTANCE(Impresora, THREAD()) &'},{{"name":"Fiscal", "instance":'& INSTANCE(Fiscal, THREAD()) &'}]')
!      MESSAGE(parser.GetError())
!      RETURN True
!    END
!    Return L:Res
!---------------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.AbrirDocumento    Procedure(String pCodigoComprobante, String pRazonSocial, String pNumeroDocumento, String pResponsabilidadIVA, | 
                                 String pTipoDocumentoCliente, String pDomicilio)

parser                          cJSONFactory

L:HayError  Byte
strJson String(1024)


GAD                            GROUP
AbrirDocumento                   GROUP
Secuencia                           LONG
Estado                              GROUP
QImpresora                             &QUEUE,NAME('Impresora')
QFiscal                                &QUEUE,Name('Fiscal')
                                    END
NumeroComprobante                     LONG
                                  END
                                END
QImpresora                       QUEUE
Str                               STRING(100)
                                END
QFiscal                          QUEUE
Str                               STRING(100)
                                END



    Code


    L:HayError=self.CargarDatosCliente(pRazonSocial,pNumeroDocumento,pResponsabilidadIVA,pTipoDocumentoCliente,pDomicilio)
    If L:HayError=True
        Return False
    End

    L:sJson='{{ ' & |
            '"AbrirDocumento": ' & |
            '{{ ' & |
            '"CodigoComprobante" : "'&Clip(Left(pCodigoComprobante))&'" ' & |
            '} ' & |
            '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('AbrirDocumento')
    If L:HayError=False

       IF NOT parser.ToGroup(L:RespBufferStr, GAD, FALSE, '[{{"name":"Impresora", "instance":'& INSTANCE(QImpresora, THREAD()) &'},{{"name":"Fiscal", "instance":'& INSTANCE(QFiscal, THREAD()) &'}]')
         MESSAGE('Error Abrir Documento: ' & parser.GetError())
         RETURN False
       END
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Abrir Documento') 
          Return False
       End 
    End
    Return GAD.AbrirDocumento.NumeroComprobante

!------------------------------------------------------------------------------------
AH2G.CargarDatosCliente   Procedure(String pRazonSocial, String pNumeroDocumento, String pResponsabilidadIVA, String pTipoDocumentoCliente, String pDomicilio)

parser                          cJSONFactory
L:HayError Byte
GCDC                          GROUP
CargarDatosCliente              GROUP
Secuencia                           STRING(20)
Estado                              GROUP
QImpresora                             &QUEUE,Name('Impresora')
QFiscal                                &QUEUE,Name('Fiscal')
                                    END
                                  END
                                END
QImpresora                       QUEUE
Str                               STRING(30)
                                END
QFiscal                          QUEUE
Str                               STRING(30)
                                END

!strJson string(1024)
!sFiscal string(1024)
!sImpresora string(1024)

  Code

      GCDC.CargarDatosCliente.Estado.QImpresora &= QImpresora
      GCDC.CargarDatosCliente.Estado.QFiscal    &= QFiscal

      L:sJson='{{ ' & |
              '"CargarDatosCliente": ' & |
              '{{ ' & |
              '"RazonSocial" : "'&Clip(Left(pRazonSocial))&'", ' & |
              '"NumeroDocumento" : "'&Clip(Left(pNumeroDocumento))&'", ' & |
              '"ResponsabilidadIVA" : "'&Clip(Left(pResponsabilidadIVA))&'", ' & |
              '"TipoDocumento" : "'&Clip(Left(pTipoDocumentoCliente))&'", ' & |
              '"Domicilio" : "'&Clip(Left(pDomicilio))&'" ' & |
              '} ' & |
              '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('CargarDatosCliente')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Cargar Datos Cliente') 
       End 
    End
    Return L:HayError


!------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.CargarDocumentoAsociado     Procedure(String pNumeroLinea, String pCodigoComprobante, String pNumeroPos, String pNumeroComprobante)
L:HayError  BYTE
    Code

    L:sJson='{{ ' & |
            '"CargarDocumentoAsociado":' & |
            '{{' & |
            '"NumeroLinea" : "'&Clip(Left(pNumeroLinea))&'",' & |
            '"CodigoComprobante" : "'&Clip(Left(pCodigoComprobante))&'",' & |
            '"NumeroPos" : "'&Clip(Left(Format(pNumeroPos,@N05)))&'",' & |
            '"NumeroComprobante" : "'&Clip(Left(Format(pNumeroComprobante,@N08)))&'"' & |
            '}' & |
            '}'


    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('CargarDocumentoAsociado')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Cargar Documento Asociado') 
       End 
    End
    Return L:HayError

!------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.CargarBeneficiario          Procedure(String pRazonSocial, String pNumeroDocumento, String pTipoDocumentoCliente, String pDomicilio)
L:HayError  BYTE
    Code

    L:sJson='{{ ' & |
            '"CargarBeneficiario":' & |
            '{{' & |
            '"RazonSocial" : "'&Clip(Left(pRazonSocial))&'",' & |
            '"NumeroDocumento" : "'&Clip(Left(pNumeroDocumento))&'",' & |
            '"TipoDocumento" : "'&Clip(Left(pTipoDocumentoCliente))&'",' & |
            '"Domicilio" : "'&Clip(Left(pDomicilio))&'"' & |
            '}' & |
            '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('CargarBeneficiario')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Cargar Beneficiario') 
       End 
    End
    Return L:HayError
!------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.CargarTransportista         Procedure(String pRazonSocial, String pCUIT, String pDomicilio, String pNombreChofer, String pTipoDocumentoCliente, | 
                                    String pNumeroDocumento, String pDominio1, String pDominio2)
L:HayError  Byte
    Code

    L:sJson='{{ ' & |
            '"CargarTransportista":' & |
            '{{' & |
            '"RazonSocial" : "'&Clip(Left(pRazonSocial))&'",' & |
            '"Cuit" : "'&Clip(Left(pCUIT))&'",' & |
            '"Domicilio" : "'&Clip(Left(pDomicilio))&'",' & |
            '"NombreChofer" : "'&Clip(Left(pNombreChofer))&'",' & |
            '"TipoDocumento" : "'&Clip(Left(pTipoDocumentoCliente))&'",' & |
            '"NumeroDocumento" : "'&Clip(Left(pNumeroDocumento))&'",' & |
            '"Dominio1" : "'&Clip(Left(pDominio1))&'",' & |
            '"Dominio2" : "'&Clip(Left(pDominio2))&'",' & |
            '}' & |
            '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('CargarTransportista')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Cargar Transportista') 
       End 
    End
    Return L:HayError
!------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.ImprimirTextoFiscal         Procedure(String pTexto, <String pAtributos>, <String pModoDisplay>)
L:Atributos String(100) 
L:HayError  BYTE   
    Code
   
    If Omitted(2) Then Clear(pAtributos).

    If pModoDisplay='' Or Omitted(3) Then pModoDisplay=AH2G:ModoDeDisplay:DisplayNo.

    If InString('DobleAncho',pAtributos,1,1)
       L:Atributos='"DobleAncho"'
    End
    If InString('Centrado',pAtributos,1,1)
       If Len(Clip(L:Atributos))=0
          L:Atributos='"Centrado"'
       Else
          L:Atributos=Clip(Left(L:Atributos)) & ',"Centrado"'
       End
    End
    If InString('Negrita',pAtributos,1,1)
       If Len(Clip(L:Atributos))=0
          L:Atributos='"Negrita"'
       Else
          L:Atributos=Clip(Left(L:Atributos)) & ',"Negrita"'
       End
    End
   
    L:sJson='{{ ' & |
            '"ImprimirTextoFiscal":' & |
            '{{' & |
            '"Atributos" : ['&Clip(Left(L:Atributos))&'],' & |
            '"Texto" : "'&Clip(Left(pTexto))&'",' & |
            '"ModoDisplay" : "'&Clip(Left(pModoDisplay))&'",' & |
            '}' & |
            '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('ImprimirTextoFiscal')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Imprimir Texto Fiscal') 
       End 
    End
    Return L:HayError

!------------------------------------------------------------------------------------------------------------------------------------------!

AH2G.ImprimirItem                Procedure(String pDescripcion, String pCantidad, String pPrecioUnitario, String pCondicionIVA, String pAlicuotaIVA, String pOperacionMonto, | 
                                String pTipoImpuestoInterno, String pMagnitudImpuestoInterno, String pModoDisplay, String pModoBaseTotal, String pUnidadReferencia, |
                                String pCodigoProducto, String pCodigoInterno, String pUnidadMedida)
L:HayError  BYTE
    Code
    If pModoDisplay='' Or Omitted(9)  Then pModoDisplay=AH2G:ModoDeDisplay:DisplayNo.

    L:sJson='{{ ' & |
            '"ImprimirItem": ' & |
            '{{ ' & |
            '"Descripcion" : "'&Clip(Left(pDescripcion))&'", ' & |
            '"Cantidad" : "'&Clip(Left(pCantidad))&'", ' & |
            '"PrecioUnitario" : "'&Clip(Left(pPrecioUnitario))&'", ' & |
            '"CondicionIVA" : "'&Clip(Left(pCondicionIVA))&'", ' & |
            '"AlicuotaIVA" : "'&Clip(Left(pAlicuotaIVA))&'", ' & |
            '"OperacionMonto" : "'&Clip(Left(pOperacionMonto))&'", ' & |
            '"TipoImpuestoInterno" : "'&Clip(Left(pTipoImpuestoInterno))&'", ' & |
            '"MagnitudImpuestoInterno" : "'&Clip(Left(pMagnitudImpuestoInterno))&'", ' & |
            '"ModoDisplay" : "'&Clip(Left(pModoDisplay))&'", ' & |
            '"ModoBaseTotal" : "'&Clip(Left(pModoBaseTotal))&'", ' & |
            '"UnidadReferencia" : "'&Clip(Left(pUnidadReferencia))&'", ' & |
            '"CodigoProducto" : "'&Clip(Left(pCodigoProducto))&'", ' & |
            '"CodigoInterno" : "'&Clip(Left(pCodigoInterno))&'", ' & |
            '"UnidadMedida" : "'&Clip(Left(pUnidadMedida))&'" ' & |
            '} ' & |
            '}'
    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('ImprimirItem')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Imprimir Item') 
       End 
    End
    Return L:HayError
!------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.ImprimirDescuentoItem   Procedure(String pDescripcio, String pMonto, String pModoDisplay, String pModoBaseTotal)
L:HayError  BYTE
    Code

    L:sJson='{{ ' & |
            '"ImprimirDescuentoItem":' & |
            '{{' & |
            '"Descripcion" : "'&Clip(Left(pDescripcio))&'",' & |
            '"Monto" : "'&Clip(Left(pMonto))&'",' & |
            '"ModoDisplay" : "'&Clip(Left(pModoDisplay))&'",' & |
            '"ModoBaseTotal" : "'&Clip(Left(pModoBaseTotal))&'"' & |
            '}' & |
            '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('ImprimirDescuentoItem')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Imprimir Descuento Item') 
       End 
    End
    Return L:HayError

!------------------------------------------------------------------------------------------------------------------------------------------!

AH2G.CerrarDocumento             Procedure(String pCopias, <String pDireccionEMail>)
L:HayError  Byte
    Code
    If Omitted(2) Then  pDireccionEMail=''.

    L:sJson='{{ ' & |
    '"CerrarDocumento": ' & |
    '{{ ' & |
    '"Copias" : "'&Clip(Left(pCopias))&'", ' & |
    '"DireccionEMail" : "'&Clip(Left(pDireccionEMail))&'" ' & |
    '} ' & |
    '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('CerrarDocumento')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Cerrar Documento') 
       End 
    End
    Return L:HayError
!------------------------------------------------------------------------------------------------------------------------------------------!

AH2G.Cancelar             Procedure()
L:HayError  Byte
    Code
    L:sJson='{{ ' & |
    '"Cancelar": ' & |
    '{{ }' & |
    '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('Cancelar')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Cancelar') 
       End 
    End
    Return L:HayError
!------------------------------------------------------------------------------------------------------------------------------------------!

AH2G.ConsultarDatosInicializacion             Procedure(Byte pInformacion)

parser                          cJSONFactory
L:HayError  Byte
GCDI                            GROUP
ConsultarDatosInicializacion  GROUP
Secuencia                           LONG
Estado                              GROUP
QImpresora                             &QUEUE,NAME('Impresora')
QFiscal                                &QUEUE,Name('Fiscal')
                                    END
CUIT                           STRING(20)
RazonSocial                    STRING(100)
Registro                       STRING(20)
NumeroPos                      STRING(5)
FechaInicioActividades         STRING(6)
IngBrutos                      STRING(20)
ResponsabilidadIVA             STRING(50)
                                  END
                                END
QImpresora                       QUEUE
Str                               STRING(100)
                                END
QFiscal                          QUEUE
Str                               STRING(100)
                                END
    Code
    L:sJson='{{ ' & |
    '"ConsultarDatosInicializacion": ' & |
    '{{ }' & |
    '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('ConsultarDatosInicializacion')
    If L:HayError=False
       IF NOT parser.ToGroup(L:RespBufferStr, GCDI, FALSE, '[{{"name":"Impresora", "instance":'& INSTANCE(QImpresora, THREAD()) &'},{{"name":"Fiscal", "instance":'& INSTANCE(QFiscal, THREAD()) &'}]')
         MESSAGE('Error Abrir Documento: ' & parser.GetError())
         RETURN False
       END
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Consultar Datos Inicializacion') 
          Return L:HayError
       End 
       Case pInformacion
            Of 1
               Return GCDI.ConsultarDatosInicializacion.CUIT
            Of 2
               Return GCDI.ConsultarDatosInicializacion.RazonSocial 
            Of 3
               Return GCDI.ConsultarDatosInicializacion.Registro
            Of 4
               Return GCDI.ConsultarDatosInicializacion.NumeroPos
            Of 5
               Return GCDI.ConsultarDatosInicializacion.FechaInicioActividades
            Of 6
               Return GCDI.ConsultarDatosInicializacion.IngBrutos
            Of 7
               Return GCDI.ConsultarDatosInicializacion.ResponsabilidadIVA
       End 

    End

    Return L:HayError

!------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.ConsultarAcumuladosComprobante Procedure(String pCodigoComprobante, String pNumeroComprobante, AH2G:SGCAC pGCAC, Byte pMostrarError)

parser                          cJSONFactory
L:HayError  Byte

GCAC                            GROUP
ConsultarAcumuladosComprobante  GROUP
Secuencia                           LONG
Estado                              GROUP
QImpresora                             &QUEUE,NAME('Impresora')
QFiscal                                &QUEUE,Name('Fiscal')
                                    END
Registro                       STRING(30)
CodigoComprobante              STRING(30)
NumeroInicial                  STRING(30)
NumeroFinal                    STRING(30)
CantidadCancelados             STRING(30)
Total                          STRING(30)
TotalExento                    STRING(30)
TotalNoGravado                 STRING(30)
TotalGravado                   STRING(30)
TotalIVA                       STRING(30)
TotalTributos                  STRING(30)
AlicuotaIVA_1                  STRING(30)
MontoIVA_1                     STRING(30)
MontoNetoSinIVA_1              STRING(30)
AlicuotaIVA_2                  STRING(30)
MontoIVA_2                     STRING(30)
MontoNetoSinIVA_2              STRING(30)
AlicuotaIVA_3                  STRING(30)
MontoIVA_3                     STRING(30)
MontoNetoSinIVA_3              STRING(30)
AlicuotaIVA_4                  STRING(30)
MontoIVA_4                     STRING(30)
MontoNetoSinIVA_4              STRING(30)
AlicuotaIVA_5                  STRING(30)
MontoIVA_5                     STRING(30)
MontoNetoSinIVA_5              STRING(30)
AlicuotaIVA_6                  STRING(30)
MontoIVA_6                     STRING(30)
MontoNetoSinIVA_6              STRING(30)
AlicuotaIVA_7                  STRING(30)
MontoIVA_7                     STRING(30)
MontoNetoSinIVA_7              STRING(30)
AlicuotaIVA_8                  STRING(30)
MontoIVA_8                     STRING(30)
MontoNetoSinIVA_8              STRING(30)
AlicuotaIVA_9                  STRING(30)
MontoIVA_9                     STRING(30)
MontoNetoSinIVA_9              STRING(30)
AlicuotaIVA_10                 STRING(30)
MontoIVA_10                    STRING(30)
MontoNetoSinIVA_10             STRING(30)
CodigoTributo1                 STRING(30)
ImporteTributo1                STRING(30)
CodigoTributo2                 STRING(30)
ImporteTributo2                STRING(30)
CodigoTributo3                 STRING(30)
ImporteTributo3                STRING(30)
CodigoTributo4                 STRING(30)
ImporteTributo4                STRING(30)
CodigoTributo5                 STRING(30)
ImporteTributo5                STRING(30)
CodigoTributo6                 STRING(30)
ImporteTributo6                STRING(30)
CodigoTributo7                 STRING(30)
ImporteTributo7                STRING(30)
CodigoTributo8                 STRING(30)
ImporteTributo8                STRING(30)
CodigoTributo9                 STRING(30)
ImporteTributo9                STRING(30)
CodigoTributo10                STRING(30)
ImporteTributo10               STRING(30)
CodigoTributo11                STRING(30)
ImporteTributo11               STRING(30)
                                  END
                                END
QImpresora                       QUEUE
Str                               STRING(100)
                                END
QFiscal                          QUEUE
Str                               STRING(100)
                                END

    Code
        L:sJson='{{ ' & |
        '"ConsultarAcumuladosComprobante": ' & |
        '{{ ' & |
        '"CodigoComprobante" : "'&Clip(Left(pCodigoComprobante))&'", ' & |
        '"NumeroComprobante" : "'&Clip(Left(pNumeroComprobante))&'" ' & |
        '} ' & |
        '}'

        L:bGetServerResponse = True
        L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
        L:HayError=self.SendRequest('ConsultarAcumuladosComprobante')
        If L:HayError=False
           IF NOT parser.ToGroup(L:RespBufferStr, GCAC, FALSE, '[{{"name":"Impresora", "instance":'& INSTANCE(QImpresora, THREAD()) &'},{{"name":"Fiscal", "instance":'& INSTANCE(QFiscal, THREAD()) &'}]')
             If pMostrarError=True Then MESSAGE('Error Abrir Documento: ' & parser.GetError()).
             Return
           END
           pGCAC.CodigoComprobante = GCAC.ConsultarAcumuladosComprobante.CodigoComprobante
           pGCAC.NumeroInicial = GCAC.ConsultarAcumuladosComprobante.NumeroInicial
           pGCAC.NumeroFinal = GCAC.ConsultarAcumuladosComprobante.NumeroFinal
           pGCAC.CantidadCancelados = GCAC.ConsultarAcumuladosComprobante.CantidadCancelados
           pGCAC.Total = GCAC.ConsultarAcumuladosComprobante.Total
           pGCAC.TotalExento = GCAC.ConsultarAcumuladosComprobante.TotalExento
           pGCAC.TotalNoGravado = GCAC.ConsultarAcumuladosComprobante.TotalNoGravado
           pGCAC.TotalGravado = GCAC.ConsultarAcumuladosComprobante.TotalGravado
           pGCAC.TotalIVA = GCAC.ConsultarAcumuladosComprobante.TotalIVA
           pGCAC.TotalTributos = GCAC.ConsultarAcumuladosComprobante.TotalTributos
           pGCAC.AlicuotaIVA_1 = GCAC.ConsultarAcumuladosComprobante.AlicuotaIVA_1
           pGCAC.MontoIVA_1 = GCAC.ConsultarAcumuladosComprobante.MontoIVA_1
           pGCAC.MontoNetoSinIVA_1 = GCAC.ConsultarAcumuladosComprobante.MontoNetoSinIVA_1
           pGCAC.AlicuotaIVA_2 = GCAC.ConsultarAcumuladosComprobante.AlicuotaIVA_2
           pGCAC.MontoIVA_2 = GCAC.ConsultarAcumuladosComprobante.MontoIVA_2
           pGCAC.MontoNetoSinIVA_2 = GCAC.ConsultarAcumuladosComprobante.MontoNetoSinIVA_2
           pGCAC.AlicuotaIVA_3 = GCAC.ConsultarAcumuladosComprobante.AlicuotaIVA_3
           pGCAC.MontoIVA_3 = GCAC.ConsultarAcumuladosComprobante.MontoIVA_3
           pGCAC.MontoNetoSinIVA_3 = GCAC.ConsultarAcumuladosComprobante.MontoNetoSinIVA_3
           pGCAC.AlicuotaIVA_4 = GCAC.ConsultarAcumuladosComprobante.AlicuotaIVA_4
           pGCAC.MontoIVA_4 = GCAC.ConsultarAcumuladosComprobante.MontoIVA_4
           pGCAC.MontoNetoSinIVA_4 = GCAC.ConsultarAcumuladosComprobante.MontoNetoSinIVA_4
           pGCAC.AlicuotaIVA_5 = GCAC.ConsultarAcumuladosComprobante.AlicuotaIVA_5
           pGCAC.MontoIVA_5 = GCAC.ConsultarAcumuladosComprobante.MontoIVA_5
           pGCAC.MontoNetoSinIVA_5 = GCAC.ConsultarAcumuladosComprobante.MontoNetoSinIVA_6
           pGCAC.AlicuotaIVA_6 = GCAC.ConsultarAcumuladosComprobante.AlicuotaIVA_6
           pGCAC.MontoIVA_6 = GCAC.ConsultarAcumuladosComprobante.MontoIVA_6
           pGCAC.MontoNetoSinIVA_6 = GCAC.ConsultarAcumuladosComprobante.MontoNetoSinIVA_6
           pGCAC.AlicuotaIVA_7 = GCAC.ConsultarAcumuladosComprobante.AlicuotaIVA_7
           pGCAC.MontoIVA_7 = GCAC.ConsultarAcumuladosComprobante.MontoIVA_7
           pGCAC.MontoNetoSinIVA_7 = GCAC.ConsultarAcumuladosComprobante.MontoNetoSinIVA_7
           pGCAC.AlicuotaIVA_8 = GCAC.ConsultarAcumuladosComprobante.AlicuotaIVA_8
           pGCAC.MontoIVA_8 = GCAC.ConsultarAcumuladosComprobante.MontoIVA_8
           pGCAC.MontoNetoSinIVA_8 = GCAC.ConsultarAcumuladosComprobante.MontoNetoSinIVA_8
           pGCAC.AlicuotaIVA_9 = GCAC.ConsultarAcumuladosComprobante.AlicuotaIVA_9
           pGCAC.MontoIVA_9 = GCAC.ConsultarAcumuladosComprobante.MontoIVA_9
           pGCAC.MontoNetoSinIVA_9 = GCAC.ConsultarAcumuladosComprobante.MontoNetoSinIVA_9
           pGCAC.AlicuotaIVA_10 = GCAC.ConsultarAcumuladosComprobante.AlicuotaIVA_10
           pGCAC.MontoIVA_10 = GCAC.ConsultarAcumuladosComprobante.MontoIVA_10
           pGCAC.MontoNetoSinIVA_10 = GCAC.ConsultarAcumuladosComprobante.MontoNetoSinIVA_10
           pGCAC.CodigoTributo1 = GCAC.ConsultarAcumuladosComprobante.CodigoTributo1
           pGCAC.ImporteTributo1 = GCAC.ConsultarAcumuladosComprobante.ImporteTributo1
           pGCAC.CodigoTributo2 = GCAC.ConsultarAcumuladosComprobante.CodigoTributo2
           pGCAC.ImporteTributo2 = GCAC.ConsultarAcumuladosComprobante.ImporteTributo2
           pGCAC.CodigoTributo3 = GCAC.ConsultarAcumuladosComprobante.CodigoTributo3
           pGCAC.ImporteTributo3 = GCAC.ConsultarAcumuladosComprobante.ImporteTributo3
           pGCAC.CodigoTributo4 = GCAC.ConsultarAcumuladosComprobante.CodigoTributo4
           pGCAC.ImporteTributo4 = GCAC.ConsultarAcumuladosComprobante.ImporteTributo4
           pGCAC.CodigoTributo5 = GCAC.ConsultarAcumuladosComprobante.CodigoTributo5
           pGCAC.ImporteTributo5 = GCAC.ConsultarAcumuladosComprobante.ImporteTributo5
           pGCAC.CodigoTributo6 = GCAC.ConsultarAcumuladosComprobante.CodigoTributo6
           pGCAC.ImporteTributo6 = GCAC.ConsultarAcumuladosComprobante.ImporteTributo6
           pGCAC.CodigoTributo7 = GCAC.ConsultarAcumuladosComprobante.CodigoTributo7
           pGCAC.ImporteTributo7 = GCAC.ConsultarAcumuladosComprobante.ImporteTributo7
           pGCAC.CodigoTributo8 = GCAC.ConsultarAcumuladosComprobante.CodigoTributo8
           pGCAC.ImporteTributo8 = GCAC.ConsultarAcumuladosComprobante.ImporteTributo8
           pGCAC.CodigoTributo9 = GCAC.ConsultarAcumuladosComprobante.CodigoTributo9
           pGCAC.ImporteTributo9 = GCAC.ConsultarAcumuladosComprobante.ImporteTributo9
           pGCAC.CodigoTributo10 = GCAC.ConsultarAcumuladosComprobante.CodigoTributo10
           pGCAC.ImporteTributo10 = GCAC.ConsultarAcumuladosComprobante.ImporteTributo10
           pGCAC.CodigoTributo11 = GCAC.ConsultarAcumuladosComprobante.CodigoTributo11
           pGCAC.ImporteTributo11 = GCAC.ConsultarAcumuladosComprobante.ImporteTributo11
        Else
           L:HayError=SELF.ConsultarUltimoError()
           If L:HayError=True
              If pMostrarError=True Then Message('Error Consultar Datos Inicializacion').
    !          Return L:HayError
           End 
        End




!------------------------------------------------------------------------------------------------------------------------------------------!

AH2G.ImprimirOtrosTributos   Procedure(String pCodigo, String pDescripcion, String pBaseImponible, String pImporte)

L:HayError  Byte
    Code
    L:sJson='{{ ' & |
    '"ImprimirOtrosTributos": ' & |
    '{{ ' & |
    '"Codigo" : "'&Clip(Left(pCodigo))&'", ' & |
    '"Descripcion" : "'&Clip(Left(pDescripcion))&'", ' & |
    '"BaseImponible" : "'&Clip(Left(pBaseImponible))&'", ' & |
    '"Importe" : "'&Clip(Left(pImporte))&'" ' & |
    '} ' & |
    '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('ImprimirOtrosTributos')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Imprimir Otros Tributos') 
       End 
    End
    Return L:HayError
!------------------------------------------------------------------------------------------------------------------------------------------!

AH2G.ImprimirPago    Procedure(String pDescripcion, String pMonto, String pOperacion, String pModoDisplay, String pDescripcionAdicional, | 
                           String pCodigoFormaPago, String pCuotas, String pCupones, String pReferencia)

L:HayError  Byte
    Code
    L:sJson='{{ ' & |
    '"ImprimirPago": ' & |
    '{{ ' & |
    '"Descripcion" : "'&Clip(Left(pDescripcion))&'", ' & |
    '"Monto" : "'&Clip(Left(pMonto))&'", ' & |
    '"Operacion" : "'&Clip(Left(pOperacion))&'", ' & |
    '"ModoDisplay" : "'&Clip(Left(pModoDisplay))&'", ' & |
    '"DescripcionAdicional" : "'&Clip(Left(pDescripcionAdicional))&'", ' & |
    '"CodigoFormaPago" : "'&Clip(Left(pCodigoFormaPago))&'", ' & |
    '"Cuotas" : "'&Clip(Left(pCuotas))&'", ' & |
    '"Cupones" : "'&Clip(Left(pCupones))&'", ' & |
    '"Referencia" : "'&Clip(Left(pReferencia))&'" ' & |
    '} ' & |
    '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('ImprimirPago')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Imprimir Pago') 
       End 
    End
    Return L:HayError

!------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.ConsultarFechaHora  Procedure(*String pFecha, *String pHora)

parser                          cJSONFactory
L:HayError  Byte


GCFH                            GROUP
ConsultarFechaHora              GROUP
Secuencia                           LONG
Estado                              GROUP
QImpresora                             &QUEUE,NAME('Impresora')
QFiscal                                &QUEUE,Name('Fiscal')
                                    END
Fecha                             STRING(10)
Hora                              STRING(10)
                                  END
                                END
QImpresora                       QUEUE
Str                               STRING(100)
                                END
QFiscal                          QUEUE
Str                               STRING(100)
                                END
    Code
    L:sJson='{{ ' & |
    '"ConsultarFechaHora": {{} ' & |
    '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('ConsultarFechaHora')
    If L:HayError=False
       IF NOT parser.ToGroup(L:RespBufferStr, GCFH, FALSE, '[{{"name":"Impresora", "instance":'& INSTANCE(QImpresora, THREAD()) &'},{{"name":"Fiscal", "instance":'& INSTANCE(QFiscal, THREAD()) &'}]')
         MESSAGE('Error Consultar Fecha y Hora: ' & parser.GetError())
!         RETURN False
       END
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Consultar Fecha y Hora') 
!          Return L:HayError
       End 
       pFecha = GCFH.ConsultarFechaHora.Fecha
       pHora  = GCFH.ConsultarFechaHora.Hora
    End
 
!------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.PedirReimpresion    Procedure()

L:HayError  Byte
    Code
    L:sJson='{{ ' & |
    '"PedirReimpresion": {{ }' & |
    '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('"PedirReimpresion')
    If L:HayError=False
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error "Pedir Reimpresion') 
       End 
    End
    Return L:HayError
!------------------------------------------------------------------------------------------------------------------------------------------!
AH2G.CopiarComprobante Procedure(String pCodigoComprobante, String pNumeroComprobante)

parser                          cJSONFactory
L:HayError  Byte

GCC                            GROUP
CopiarComprobante                 GROUP
Secuencia                           LONG
Estado                              GROUP
QImpresora                             &QUEUE,NAME('Impresora')
QFiscal                                &QUEUE,Name('Fiscal')
                                    END
                                  END
                                END
QImpresora                       QUEUE
Str                               STRING(100)
                                END
QFiscal                          QUEUE
Str                               STRING(100)
                                END
    Code
    L:sJson='{{ ' & |
    '"CopiarComprobante": ' & |
    '{{ ' & |
    '"CodigoComprobante" : "'&Clip(Left(pCodigoComprobante))&'", ' & |
    '"NumeroComprobante" : "'&Clip(Left(pNumeroComprobante))&'" ' & |
    '} ' & |
    '}'

    L:bGetServerResponse = True
    L:sUrl=Clip(Left(SELF.sURLPrinter)) & Clip(Left(SELF.sXMLFiscal))
    L:HayError=self.SendRequest('CopiarComprobante')
    If L:HayError=False
       IF NOT parser.ToGroup(L:RespBufferStr, GCC, FALSE, '[{{"name":"Impresora", "instance":'& INSTANCE(QImpresora, THREAD()) &'},{{"name":"Fiscal", "instance":'& INSTANCE(QFiscal, THREAD()) &'}]')
         MESSAGE('Error Copiar Comprobante: ' & parser.GetError())
         RETURN False
       END
       L:HayError=SELF.ConsultarUltimoError()
       If L:HayError=True
          Message('Error Consultar Datos Inicializacion') 
          Return L:HayError
       End 
    End

    Return L:HayError

!------------------------------------------------------------------------------------------------------------------------------------------!

AH2G.SendRequest       Procedure(String pCommando)
L:HayError  Byte
jResp   &cJSON 

    Code
    curl.Init()
    curl.FreeHttpHeaders()    
    curl.AddHttpHeader('Content-Type: application/json')
    curl.SetHttpHeaders()

!    L:RespBuffer &= NewDynStr()

    L:HayError=False

    curl.SetCustomRequest('POST')
    curl.SetSSLVerifyHost(False)  
    curl.SetSSLVerifyPeer(False)

    IF L:bGetServerResponse
        L:Res = curl.SetHttpGET(TRUE)
        IF L:Res <> CURLE_OK
            MESSAGE('SetHttpGET failed: '& curl.StrError(L:Res), 'libcurl', ICON:Exclamation)
            L:HayError=True
            Return L:HayError
        END
    END
    L:RespBuffer.Trunc(0)
    
    L:Res = curl.SendRequest(L:sUrl, L:sJson, L:RespBuffer.GetInterface())
    If L:Res <> CURLE_OK
        MESSAGE('SendRequest failed: '& curl.StrError(L:Res), 'libcurl', ICON:Exclamation)
        L:HayError=True
        Return L:HayError
    Else
        jResp &= jsonFactory.Parse(L:RespBuffer.Str()) 

        Case pCommando
            Of 'ConsultarUltimoError'
                Clear(L:ErrorRespBufferStr)
                L:ErrorRespBufferStr = jResp.ToString()
            Else
                Clear(L:RespBufferStr)
                L:RespBufferStr = jResp.ToString()
        End

        L:HayError=False
    End
    jResp.Delete()
    jResp.Destruct()
    L:RespBuffer.Kill
    L:bGetServerResponse = False 
    Return L:HayError
!------------------------------------------------------------------------------------------------------------------------------------------!
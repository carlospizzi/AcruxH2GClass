!ABCIncludeFile(Family)

OMIT('***')
 * User: Carlos Pizzi
 * Date: 28/11/2018
 *
 * 
 *  Lo que mas abajo no se si es así o al revés... probar !!!
*   Definir en el proyecto para DLL
 * _AH2GLinkMode_=>1
 * _AH2GDllMode_=>0
 *
 *
 * Definir para EXE
 * _AH2GLinkMode_=>0
 * _AH2GDllMode_=>1


 ***



AH2G             Class,Module('AcruxH2GClass.clw'),Link('AcruxH2GClass.clw',_AH2GLinkMode_), DLL(_AH2GDllMode_)




sURLPrinter String(300)
sXMLFiscal  String(10)
InDebug     Byte
GSA          &GSalida



Construct           Procedure()
Destruct            Procedure()
Init                Procedure()
Kill                Procedure()




!!!<summary>Este comando permite consultar información asociada al error reportado por la impresora fiscal al intentar</summary>
!!!<summary>ejecutar el último comando enviado.</summary>
ConsultarUltimoError Procedure(),Byte


!!!<summary>Este comando permite consultar el estado general de la impresora fiscal, e información asociada al último tipo de</summary>
!!!<summary>comprobante emitido/cancelado que se especifique.</summary>
!!!<param name="pCodigoComprobante"> El tipo de comprobante a especificar debe ser alguno de los códigos identificatorios tabulados en la normativa
!!!fiscal vigente. (AH2G:TipoComprobante). Default: AH2G:TipoComprobante:NoDocumento</param>
!!!<returns>Devuelve un String en formato JSON. Devuelve el estado general de la impresora. Leer Manual de Comandos.</returns>
ConsultarEstado Procedure(String pCodigoComprobante),String

ConsultarEstadoII Procedure(String pCodigoComprobante, *AH2G:GSalida pGSalida)


!!!<summary>Este comando permite abrir cualquier comprobante disponible para su emisión en la impresora fiscal.</summary> 
!!!<summary>Tenerpresente que para la apertura del comprobante en algunos casos se requiere de uno o más comandos previos en</summary>
!!!<summary>forma obligatoria, como por ejemplo: CargarDatosCliente, CargarDocumentoAsociado, y/u otros.</summary>
!!!<summary>En el caso de emisión del Documento Donación se requiere además, antes de la apertura del comprobante, del</summary>
!!!<summary>envío del comando CargarBeneficiario.</summary>
!!!<summary>En el caso de emisión de un Remito ('R' o 'X') se requiere además, antes de la apertura del comprobante, del envío</summary>
!!!<summary>del comando CargarTransportista.</summary>
!!!<summary>El comando AbrirDocumento es el que imprime el encabezado del mismo.</summary>
!!!<param name="pCodigoComprobante" El tipo de comprobante a especificar debe ser alguno de los códigos identificatorios tabulados en la normativa fiscal vigente. (AH2G:TipoComprobante)</param>
!!!<param name="pRazonSocial" Razón Social del cliente.</param>
!!!<param name="pNumeroDocumento" Número del Documento del cliente.</param>
!!!<param name="pResponsabilidadIVA" Responsabilidad IVA del cliente. (AH2G:ResponsabilidadIVA)</param>
!!!<param name="pTipoDocumentoCliente" Tipo de Documento del cliente. (AH2G:TipoDocumentoCliente)</param>
!!!<param name="pDomicilio" Domicilio del cliente.</param>
!!!<returns>Número De Comprobante | Cero o False=Error</returns>
AbrirDocumento  Procedure(String pCodigoComprobante, String pRazonSocial, String pNumeroDocumento, String pResponsabilidadIVA, | 
                          String pTipoDocumentoCliente, String pDomicilio),Long

CargarDatosCliente Procedure(String pRazonSocial, String pNumeroDocumento, String pResponsabilidadIVA, String pTipoDocumentoCliente, String pDomicilio),Byte,PRIVATE


!!!<summary>Este comando permite almacenar, en la memoria de trabajo de la impresora fiscal, información identificatoria de</summary>
!!!<summary>un comprobante determinado. Dicha información vincula al comprobante próximo a emitir y al referenciado (o asociado).</summary>
!!!<param name="pNumeroLinea" Entre 0 y 2.</param>
!!!<param name="pCodigoComprobante" (TiposComprobante).</param>
!!!<param name="pNumeroPos" Entre 0 y 99999.</param>
!!!<param name="pNumeroComprobant" Entre 0 y 99999999.</param>
!!!<returns>True=Error o False=Todo bien </returns>
CargarDocumentoAsociado Procedure(String pNumeroLinea, String pCodigoComprobante, String pNumeroPos, String pNumeroComprobante),Byte


!!!<summary>Este comando permite almacenar los datos del beneficiario de una donación en la memoria de trabajo de la</summary>
!!!<summary>impresora fiscal, y para su posterior impresión en el encabezado de un Comprobante Donación próximo a emitir.</summary>
!!!<param name="pRazonSocial" Razón Social del beneficiario.</param>
!!!<param name="pNumeroDocumento" Número del Documento del beneficiario.</param>
!!!<param name="pTipoDocumentoCliente" Tipo de Documento del cliente. (AH2G:TipoDocumentoCliente)</param>
!!!<param name="pDomicilio" Domicilio del beneficiario.</param>
!!!<returns>True=Error o False=Todo bien </returns>
CargarBeneficiario Procedure(String pRazonSocial, String pNumeroDocumento, String pTipoDocumentoCliente, String pDomicilio),Byte


!!!<summary>Este comando permite almacenar los datos del transportista en la memoria de trabajo de la impresora fiscal, y</summary>
!!!<summary>para su posterior impresión en el Remito ('R' ó 'X') próximo a emitir. El comando CargarTransportista</summary>
!!!<summary>debe enviarse antes del comando de apertura del Remito ('R' ó 'X'), ya que es este último comando quien realiza la</summary>
!!!<summary>impresión.</summary>
!!!<param name="pRazonSocial"> Razón Social del transportista.</param>
!!!<param name="pCUIT"> CUIT del transportista.</param>
!!!<param name="pDomicilio"> Domicilio del transportista.</param> 
!!!<param name="pNombreChofer"> Nombre del chofer.</param>
!!!<param name="pTiposDeDocumentoCliente"> Enumeración (TiposDeDocumentoCliente)</param>
!!!<param name="pNumeroDocumento"> Número del Documento del chofer.</param>
!!!<param name="pDominio1"> Dominio 1 del chofer.</param>
!!!<param name="pDominio2"> Dominio 2 del chofer.</param>
!!!<returns>True=Error o False=Todo bien </returns>
CargarTransportista Procedure(String pRazonSocial, String pCUIT, String pDomicilio, String pNombreChofer, String pTiposDeDocumentoCliente, String pNumeroDocumento, String pDominio1, String pDominio2),Byte


!!!<summary>Este comando permite extender la descripción de un ítem, y debe enviarse en forma previa a la impresión del</summary>
!!!<summary>ítem cuya descripción extiende. El comando ImprimirTextoFiscal puede ser enviado hasta un máximo de</summary>
!!!<summary>4 veces consecutivas en forma previa a la impresión del ítem.</summary>
!!!<param name="pTexto"> Texto a Imprimir.</param>
!!!<param name="pAtributos"> Pude ser DobleAncho, Centrado, Negrita o la combinatoria de los tres atributos separado por una coma.</param>
!!!<param name="pModoDisplay"> Toma el valor DisplayNo o DisplaySi. Default: DisplayNo).</param>
!!!<returns>True=Error o False=Todo bien </returns>
ImprimirTextoFiscal         Procedure(String pTexto, <String pAtributos>, <String pModoDisplay>),Byte


!!!<summary>Este comando permite la impresión de un ítem en el comprobante. En caso de ser necesario extender la</summary>
!!!<summary>descripción del ítem, en forma previa a este comando se puede enviar (hasta un máximo de 4 veces consecutivas)</summary>
!!!<summary>el comando ImprimirTextoFiscal.</summary>
!!!<summary>Para mas detalle del comando ir al manual de comandos</summary>
!!!<param name="pDescripcion">Descripción.</param>
!!!<param name="pCantidad">Cantidad. Máxima cantidad de dígitos enteros: 9. Máxima cantidad de dígitos decimales: 9</param>
!!!<param name="pPrecioUnitario">Precio por unidad de medida. Máxima cantidad de dígitos enteros: 9.Máxima cantidad de dígitos decimales: 4</param>
!!!<param name="pCondicionIVA">Condición de IVA. Enumeración (AH2G:CondicionIVA:)</param>
!!!<param name="pAlicuotaIVA">Alícuota de IVA (nn.nn). Máxima cantidad de dígitos enteros: 2. Máxima cantidad de dígitos decimales: 2. Valor por omisión: 0.00</param>
!!!<param name="pOperacionMonto">Operación de suma o resta. Enumeración (AH2G:ModoDeMonto:)</param>
!!!<param name="pTipoImpuestoInterno">Tipo de Impuesto Interno. Enumeración (AH2G:ModoDeImpuestosInternos:). Valor por omisión: IIVariableKIVA (0)</param>
!!!<param name="pMagnitudImpuestoInterno">Magnitud del Impuesto Interno -coeficiente/monto/porcentaje. Máxima cantidad de dígitos enteros: 9. Máxima cantidad de dígitos decimales: 8</param>
!!!<param name="pModoDisplay"> Toma el valor DisplayNo o DisplaySi. Default: DisplayNo).</param>
!!!<param name="pModoBaseTotal">Operación por Base o por Total. ModoPrecioBase=Precio base especificado. ModoPrecioTota=Precio total especificado.</param>
!!!<param name="pUnidadReferencia">Unidad de referencia. Rango permitido: Entre 0 y 99999999</param>
!!!<param name="pCodigoProducto">Código Producto/Servicio. (De Barra)Se trata de una codificación cuya estructura es la provista por la Asociación Argentina de Codificación de Productos Comerciales. Ver Manual</param>
!!!<param name="pCodigoInterno">Código interno del sistema.</param>
!!!<param name="pUnidadMedida">Código unidad de medida. Enumeración (AH2G:UnidadMedida:) Valor por omisión: AH2G:UnidadMedida:Unidad</param>
!!!<returns>True=Error o False=Todo bien </returns>
ImprimirItem  Procedure(String pDescripcion, String pCantidad, String pPrecioUnitario, String pCondicionIVA, String pAlicuotaIVA, String pOperacionMonto, | 
                        String pTipoImpuestoInterno, String pMagnitudImpuestoInterno, String pModoDisplay, String pModoBaseTotal, String pUnidadReferencia, |
                        String pCodigoProducto, String pCodigoInterno, String pUnidadMedida),Byte



!!!<summary>Este comando permite la impresión de un descuento aplicado sobre el último ítem incluido en el comprobante.</summary>
!!!<summary>Si bien el comando ImprimirDescuentoItem es aceptado en un Recibo 'X', la generación de dicho</summary>
!!!<summary>comprobante puede resolverse empleando únicamente el comando Imprimiritem. En los casos de emisión de</summary>
!!!<summary>Remitos 'R' o 'X', y Documento Donación, el comando ImprimirDescuentoItem no es aceptado.</summary>
!!!<param name="pDescripcion">Descripción.</param>
!!!<param name="pMonto">Monto del Descuento. Máxima cantidad de dígitos enteros: 9. Máxima cantidad de dígitos decimales: 2</param>
!!!<param name="pModoDisplay"> Toma el valor DisplayNo o DisplaySi. Default: DisplayNo).</param>
!!!<param name="pModoBaseTotal">Operación por Base o por Total. ModoPrecioBase=Precio base especificado. ModoPrecioTota=Precio total especificado.</param>
!!!<returns>True=Error o False=Todo bien </returns>
ImprimirDescuentoItem   Procedure(String pDescripcio, String pMonto, String pModoDisplay, String pModoBaseTotal),Byte


CerrarDocumento             Procedure(String pCopias, <String pDireccionEMail>),Byte

Cancelar                    Procedure(),Byte

CierreX                     Procedure(),Byte

CierreZ                     Procedure(),Byte

!!!<summary>Este comando permite consultar los datos fiscales del emisor de los comprobantes.</summary>
!!!<param name="pInformacion">Número de dato a devolver: 1=CUIT, 2=RazonSocial, 3=Registro, 4=NumeroPos, 5=FechaInicioActividades, 6=IngBrutos, 7=ResponsabilidadIVA</param>
ConsultarDatosInicializacion Procedure(Byte pInformacion),String

!ConsultarAcumuladosComprobanteOLD Procedure(String pCodigoComprobante, String pNumeroComprobante, Byte pInformacion),String

ConsultarAcumuladosComprobante Procedure(String pCodigoComprobante, String pNumeroComprobante, AH2G:SGCAC pGCAC, Byte pMostrarError)

ImprimirOtrosTributos   Procedure(String pCodigo, String pDescripcion, String pBaseImponible, String pImporte),Byte

ImprimirPago    Procedure(String pDescripcion, String pMonto, String pOperacion, String pModoDisplay, String pDescripcionAdicional, String pCodigoFormaPago, String pCuotas, String pCupones, String pReferencia),Byte        

ConsultarFechaHora   Procedure(*String pFecha, *String pHora)

PedirReimpresion    Procedure(),Byte

CopiarComprobante Procedure(String pCodigoComprobante, String pNumeroComprobante),Byte

SendRequest                 Procedure(String pCommando),Byte




                        End
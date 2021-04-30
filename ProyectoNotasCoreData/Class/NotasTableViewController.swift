//
//  NotasTableViewController.swift
//  ProyectoNotasCoreData
//
//  Created by user on 14/4/21.
//

import UIKit
import CoreData

class NotasTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var notas = [Notas]()
    var fetchResultController : NSFetchedResultsController<Notas>!
    var categoriaNotas : Categorias!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = categoriaNotas.nombre
        
        let buttonAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(agregarNota))
        navigationItem.rightBarButtonItem = buttonAdd
        
        mostrarNotas()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notas.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CeldaTableViewCell
        let nota = notas[indexPath.row]
        cell.titulo.text = nota.titulo
        let formatoFecha = DateFormatter()
        formatoFecha.dateStyle = .full
        let fecha = formatoFecha.string(from: nota.fecha!)
        cell.fecha.text = fecha

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editarNota", sender: self)
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let eliminar = UITableViewRowAction(style: .destructive, title: "Eliminar") { (_, indexPath) in
            print("Eliminar")
            let contexto = Conexion().contexto()
            let borrar = self.fetchResultController.object(at: indexPath)
            contexto.delete(borrar)
            do{
                try contexto.save()
            }catch let error as NSError{
                print("Error al borrar", error.localizedDescription)
                
            }
        }
        
        /*let camara = UITableViewRowAction(style: .normal, title: "Foto") { (_, indexPath) in
            self.performSegue(withIdentifier: "fotos", sender: indexPath)
        }*/
        return [eliminar]
    }
    //MARK: AGREGAR NOTAS
    @objc func agregarNota(){
        performSegue(withIdentifier: "agregarNota", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "agregarNota"{
            let destino = segue.destination as! AgregarNotasViewController
            destino.categoriaAddNota = categoriaNotas
            destino.editarGuardar = true
        }
        if segue.identifier == "editarNota"{
            if let id = tableView.indexPathForSelectedRow{
                let fila = notas[id.row]
                let destino = segue.destination as! AgregarNotasViewController
                destino.notas = fila
                destino.editarGuardar = false
            }
        }
        if segue.identifier == "foto"{
            let id = sender as! NSIndexPath
            let fila = notas[id.row]
            let destino = segue.destination as! ImagenesCollectionViewController
            destino.notas = fila
            
        }
    }
    
    //MARK: FETCHRESULTCONTROLER
    
    func mostrarNotas(){
        let contexto = Conexion().contexto()
        let fetchRequest : NSFetchRequest<Notas> = Notas.fetchRequest()
        
        let orderByNombre = NSSortDescriptor(key: "titulo", ascending: true)
        fetchRequest.sortDescriptors = [orderByNombre]
        //Esto del predicate es para que muestre la informacion de la nota del ID que corresponda la nota y no muestre el contenido en otras notas
        let id_cat = categoriaNotas.id
        fetchRequest.predicate = NSPredicate(format: "id_categoria == %@", id_cat! as CVarArg)
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            notas = fetchResultController.fetchedObjects!
        } catch let error as NSError {
            print("Hubo un error al mostrar datos", error.localizedDescription)
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .fade)
        default:
            self.tableView.reloadData()
        }
        //Cambiar la tabla Categorias por la tabla que necesitemos
        self.notas = controller.fetchedObjects as! [Notas]
    }
}

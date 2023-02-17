//A FAIRE

//Belle UI pour changer les paramètres
//Optimisation :D

/*
idées : 
- si y'a assez de gens dans ta subdiv, ne prendre en compte qu'eux


*/
module main
import gg
import gx
import rand as rd
import math as m

const (
    win_width    = 640  //  /!\ the size must be un multiple du radius de détection
    win_height   = 640
    bg_color     = gx.white
    nb_boids = 700
    boid_size = 2
    speed = 0.005
    detect_radius = 20
    pow_detec_radius = detect_radius*detect_radius
    pow_trop_pres = 12
    cohesion = 1
    separation = 40
    alignement = 0.1
    friction_reduc = 0.9
    max_crea_trop_proche = 7
)

[heap]
struct Boid{
    mut:
    x f64
    y f64
    dir_x f64
    dir_y f64
    delta_dir_x f64
    delta_dir_y f64
}


struct App {
mut:
    gg    &gg.Context = unsafe { nil }
	boids []Boid
    opti_list [][][]&Boid = [][][]&Boid{len:win_width/detect_radius, init:[][]&Boid{len:win_height/detect_radius, init:[]&Boid{cap:10}}}
}



fn main() {
    mut app := &App{
        gg: 0
    }
    app.gg = gg.new_context(
        width: win_width
        height: win_height
        create_window: true
        window_title: '- Boids -'
        user_data: app
        bg_color: bg_color
        frame_fn: on_frame
        sample_count: 6
        fullscreen: true
    )
    for _ in 0..nb_boids{
        app.boids << Boid{rd.int_in_range(0, win_width)!, rd.int_in_range(0, win_height)!, rd.f64_in_range(-1.0, 1.0)!, rd.f64_in_range(-1.0, 1.0)!, 0.0, 0.0}
    }
    //lancement du programme/de la fenêtre
    app.gg.run()
}


fn (mut app App) store_boids_opti_grid(){
    for mut boid in app.boids{
        //store to the right list
        for boid.x >= win_width{
            boid.x -= win_width
        }
        for boid.x < 0{
            boid.x += win_width
        }
        for boid.y >= win_height{
            boid.y -= win_height
        }
        for boid.y < 0{
            boid.y += win_height
        }
        i := int(boid.x/detect_radius)
        j := int(boid.y/detect_radius)
        app.opti_list[i][j] << &boid
    }
}


fn on_frame(mut app App) {
    //Draw
    app.store_boids_opti_grid()
    app.gg.begin()
    for mut boid in app.boids{
        mut boids_trop := []Boid{}
        mut boids_normal := []Boid{}
        i := int(boid.x/detect_radius)
        j := int(boid.y/detect_radius)
        for l in -1..2{
            for c in -1..2{
                if i + l < 0{
                    if j+c < 0{
                        for other in app.opti_list[i+l+win_height/detect_radius][j+c+win_width/detect_radius]{
                            dist := m.pow(m.abs(boid.x - (other.x - win_width)),2)+m.pow(m.abs(boid.y - (other.y - win_height)),2)
                            if dist < pow_detec_radius{
                                new_crea := Boid{other.x-win_width, other.y-win_height, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                if dist < pow_trop_pres{
                                    boids_trop << new_crea 
                                }else{
                                    boids_normal << new_crea
                                }
                            }
                        }
                    }else if j+c >= win_height/detect_radius{
                        for other in app.opti_list[i+l+win_height/detect_radius][j+c-win_width/detect_radius]{
                            dist := m.pow(m.abs(boid.x - (other.x + win_width)),2)+m.pow(m.abs(boid.y - (other.y - win_height)),2)
                            if dist < pow_detec_radius{
                                new_crea := Boid{other.x+win_width, other.y-win_height, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                if dist < pow_trop_pres{
                                    boids_trop << new_crea 
                                }else{
                                    boids_normal << new_crea
                                }
                            }
                        }
                    }else{
                        for other in app.opti_list[i+l+win_height/detect_radius][j+c]{
                            dist := m.pow(m.abs(boid.x - other.x),2)+m.pow(m.abs(boid.y - (other.y - win_height) ),2)
                            if dist < pow_detec_radius{
                                new_crea := Boid{other.x, other.y-win_height, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                if dist < pow_trop_pres{
                                    boids_trop << new_crea 
                                }else{
                                    boids_normal << new_crea
                                }
                            }
                        }
                    }
                }else if i+l >= win_width/detect_radius{
                    if j+c < 0{
                        for other in app.opti_list[i+l-win_height/detect_radius][j+c+win_width/detect_radius]{
                            dist := m.pow(m.abs(boid.x - (other.x - win_width)),2)+m.pow(m.abs(boid.y - (other.y + win_height)),2)
                            if dist < pow_detec_radius{
                                new_crea := Boid{other.x-win_width, other.y+win_height, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                if dist < pow_trop_pres{
                                    boids_trop << new_crea 
                                }else{
                                    boids_normal << new_crea
                                }
                            }
                        }
                    }else if j+c >= win_height/detect_radius{
                        for other in app.opti_list[i+l-win_height/detect_radius][j+c-win_width/detect_radius]{
                            dist := m.pow(m.abs(boid.x - (other.x + win_width)),2)+m.pow(m.abs(boid.y - (other.y + win_height)),2)
                            if dist < pow_detec_radius{
                                new_crea := Boid{other.x+win_width, other.y+win_height, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                if dist < pow_trop_pres{
                                    boids_trop << new_crea 
                                }else{
                                    boids_normal << new_crea
                                }
                            }
                        }
                    }else{
                        for other in app.opti_list[i+l-win_height/detect_radius][j+c]{
                            dist := m.pow(m.abs(boid.x - other.x),2)+m.pow(m.abs(boid.y - (other.y + win_height)),2)
                            if dist < pow_detec_radius{
                                new_crea := Boid{other.x, other.y+win_height, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                if dist < pow_trop_pres{
                                    boids_trop << new_crea 
                                }else{
                                    boids_normal << new_crea
                                }
                            }
                        }
                    }
                }else{
                    if j+c < 0{
                        for other in app.opti_list[i+l][j+c+win_width/detect_radius]{
                            dist := m.pow(m.abs(boid.x - (other.x-win_width)),2)+m.pow(m.abs(boid.y - other.y),2)
                            if dist < pow_detec_radius{
                                new_crea := Boid{other.x-win_width, other.y, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                if dist < pow_trop_pres{
                                    boids_trop << new_crea 
                                }else{
                                    boids_normal << new_crea
                                }
                            }
                        }
                    }else if j+c >= win_height/detect_radius{
                        for other in app.opti_list[i+l][j+c-win_width/detect_radius]{
                            dist := m.pow(m.abs(boid.x - (other.x+win_width)),2)+m.pow(m.abs(boid.y - other.y),2)
                            if dist < pow_detec_radius{
                                new_crea := Boid{other.x+win_width, other.y, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                if dist < pow_trop_pres{
                                    boids_trop << new_crea 
                                }else{
                                    boids_normal << new_crea
                                }
                            }
                        }
                    }else{
                        for other in app.opti_list[i+l][j+c]{
                            dist := m.pow(m.abs(boid.x - other.x),2)+m.pow(m.abs(boid.y - other.y),2)
                            if dist < pow_detec_radius{
                                if dist < pow_trop_pres{
                                    boids_trop << other
                                }else{
                                    boids_normal << other
                                }
                            }
                        }
                    }
                }
            }
        }
        nb_near := boids_trop.len + boids_normal.len

        mut posi_cible_cohesion_x := 0.0
        mut posi_cible_cohesion_y := 0.0
        mut average_dir_x := 0.0
        mut average_dir_y := 0.0
        mut delta_repoussage_x := 0.0
        mut delta_repoussage_y := 0.0
        if boids_trop.len > max_crea_trop_proche{
            mut index := 0
            for _ in 0..max_crea_trop_proche{
                index = rd.int_in_range(0, boids_trop.len)or {panic(err)}
                posi_cible_cohesion_x += boids_trop[index].x
                posi_cible_cohesion_y += boids_trop[index].y
                delta_repoussage_x += boids_trop[index].x
                delta_repoussage_y += boids_trop[index].y
                average_dir_x += boids_trop[index].dir_x
                average_dir_y += boids_trop[index].dir_y
                boids_trop.delete(index)
            }
            posi_cible_cohesion_x /= max_crea_trop_proche
            posi_cible_cohesion_y /= max_crea_trop_proche
            delta_repoussage_x /= max_crea_trop_proche
            delta_repoussage_y /= max_crea_trop_proche
            average_dir_x /= max_crea_trop_proche
            average_dir_y /= max_crea_trop_proche
            delta_repoussage_x = boid.x - delta_repoussage_x
            delta_repoussage_y = boid.y - delta_repoussage_y
            posi_cible_cohesion_x -= boid.x
            posi_cible_cohesion_y -= boid.y
        }else{
            for other in boids_trop{
                posi_cible_cohesion_x += other.x
                posi_cible_cohesion_y += other.y
                delta_repoussage_x += other.x
                delta_repoussage_y += other.y
                average_dir_x += other.dir_x
                average_dir_y += other.dir_y
            }
            for other in boids_normal{
                posi_cible_cohesion_x += other.x
                posi_cible_cohesion_y += other.y
                average_dir_x += other.dir_x
                average_dir_y += other.dir_y
            }        
            posi_cible_cohesion_x /= nb_near
            posi_cible_cohesion_y /= nb_near
            delta_repoussage_x /= boids_trop.len
            delta_repoussage_y /= boids_trop.len
            average_dir_x /= nb_near
            average_dir_y /= nb_near
            delta_repoussage_x = boid.x - delta_repoussage_x
            delta_repoussage_y = boid.y - delta_repoussage_y
            posi_cible_cohesion_x -= boid.x
            posi_cible_cohesion_y -= boid.y
        }

        boid.dir_x += average_dir_x*alignement + posi_cible_cohesion_x*cohesion + delta_repoussage_x*separation
        boid.dir_y += average_dir_y*alignement + posi_cible_cohesion_y*cohesion + delta_repoussage_y*separation
        boid.x += boid.dir_x*speed
        boid.y += boid.dir_y*speed

        boid.dir_x *= friction_reduc
        boid.dir_y *= friction_reduc


        //draw
        mut red_color := u8(0)
        if nb_near*6 > 255{
            red_color = 255
        }else{
            red_color += u8(nb_near*6)
        }
        mut blue_color := u8(0)
        if boids_trop.len*20 > 255{
            blue_color = 255
        }else{
            blue_color += u8(boids_trop.len*20)
        }
        
        app.gg.draw_circle_filled(f32(boid.x +50), f32(boid.y+60), boid_size, gx.Color{red_color, 0, blue_color, 255})
    }
    app.gg.end()
    app.opti_list = [][][]&Boid{len:win_width/detect_radius, init:[][]&Boid{len:win_height/detect_radius, init:[]&Boid{cap:10}}}
}

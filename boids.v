//A FAIRE

//Après : refonte du mvt




module main
import gg
import gx
import rand as rd
import math as m

const (
    win_width    = 600
    win_height   = 600
    bg_color     = gx.white
    nb_boids = 500
    boid_size = 2
    speed = 0.1
    detect_radius = 20
    pow_detec_radius = detect_radius*detect_radius
    pow_trop_pres = 10
    cohesion = 1
    separation = 30
    alignement = 30
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
        sample_count: 10
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
        for other in boids_trop{
            posi_cible_cohesion_x += other.x
            posi_cible_cohesion_y += other.y
            delta_repoussage_x += other.x
            delta_repoussage_y += other.y
        }
        for other in boids_normal{
            posi_cible_cohesion_x += other.x
            posi_cible_cohesion_y += other.y
        }
        posi_cible_cohesion_x /= nb_near
        posi_cible_cohesion_y /= nb_near
        delta_repoussage_x /= boids_trop.len
        delta_repoussage_y /= boids_trop.len
        delta_repoussage_x = boid.x - delta_repoussage_x
        delta_repoussage_y = boid.y - delta_repoussage_y
        posi_cible_cohesion_x -= boid.x
        posi_cible_cohesion_y -= boid.y

        boid.dir_x += average_dir_x + posi_cible_cohesion_x*cohesion + delta_repoussage_x*separation
        boid.dir_y += average_dir_y + posi_cible_cohesion_y*cohesion + delta_repoussage_y*separation
        boid.x += boid.dir_x/10*speed
        boid.y += boid.dir_y/10*speed

        boid.dir_x *= 0.9
        boid.dir_y *= 0.9


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
        
        app.gg.draw_circle_filled(f32(boid.x), f32(boid.y), boid_size, gx.Color{red_color, 0, blue_color, 255})
    }
    app.gg.end()
    app.opti_list = [][][]&Boid{len:win_width/detect_radius, init:[][]&Boid{len:win_height/detect_radius, init:[]&Boid{cap:10}}}
}
